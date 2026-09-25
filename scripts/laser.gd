extends RayCast2D

@onready var line_2d: Line2D = $Line2D

const CAST_SPEED := 7000.0
const MAX_LENGTH := 1400.0
const GROWTH_TIME := 0.1
const DAMAGE_TIME := 0.01
const LASER_DAMAGE := 1

var is_casting := false:
	set = set_is_casting

var tween: Tween = null
var laser_target: Vector2 = Vector2.ZERO
var damage_timer: float = 0.0

var is_clashing := false
var clash_point: Vector2 = Vector2.ZERO
var clashing_laser: RayCast2D = null


func _ready() -> void:
	add_to_group("lasers")

	line_2d.set_point_position(0, Vector2.ZERO)
	line_2d.set_point_position(1, Vector2.ZERO)
	line_2d.visible = false

	set_is_casting(is_casting)


func _physics_process(delta: float) -> void:
	if not is_casting:
		return

	# Beam clash
	if is_clashing:
		if clashing_laser == null or not clashing_laser.is_casting:
			is_clashing = false
			clashing_laser = null
			clash_point = Vector2.ZERO
		else:
			line_2d.set_point_position(1, to_local(clash_point))

			Global.explosion.boom(
				clash_point,
				line_2d.default_color,
				"LaserExplode"
			)

			return

	# Laser growth
	laser_target.x = move_toward(
		laser_target.x,
		MAX_LENGTH,
		CAST_SPEED * delta
	)

	target_position = laser_target
	force_raycast_update()

	# Raycast collision
	var laser_end_position: Vector2 = laser_target

	if is_colliding():
		var boom_point: Vector2 = get_collision_point()

		laser_end_position = to_local(boom_point)
		laser_target = laser_end_position
		target_position = laser_target

		Global.explosion.boom(
			boom_point,
			line_2d.default_color,
			"LaserExplode"
		)

		var collider = get_collider()

		damage_timer += delta

		if damage_timer >= DAMAGE_TIME:
			if collider and collider.has_method("take_damage"):
				collider.take_damage(LASER_DAMAGE)

			damage_timer = 0.0

		if collider:
			if collider.name == "Missile" or collider.name == "Bullet":
				Global.explosion.boom(
					boom_point,
					collider.color,
					collider.name + "Explode"
				)

				collider.queue_free()
	else:
		damage_timer = 0.0

	# Laser clash detection
	var laser_start: Vector2 = global_position
	var laser_end: Vector2 = to_global(laser_end_position)

	var clash_result: Array = find_laser_intersection(
		laser_start,
		laser_end
	)

	if clash_result.size() > 0:
		var intersection: Vector2 = clash_result[0]
		var other_laser: RayCast2D = clash_result[1]

		var laser_distance := laser_start.distance_to(intersection)
		var object_distance := INF

		if is_colliding():
			object_distance = laser_start.distance_to(
				get_collision_point()
			)

		if laser_distance < object_distance:
			start_beam_clash(
				intersection,
				other_laser
			)

			return

	line_2d.set_point_position(
		1,
		laser_end_position
	)


func find_laser_intersection(
	start_point: Vector2,
	end_point: Vector2
) -> Array:

	var closest_point: Vector2 = Vector2.ZERO
	var closest_laser: RayCast2D = null
	var closest_distance: float = INF

	for node in get_tree().get_nodes_in_group("lasers"):
		var other: RayCast2D = node as RayCast2D

		if other == null:
			continue

		if other == self:
			continue

		if get_instance_id() > other.get_instance_id():
			continue

		if not other.is_casting:
			continue

		if other.is_clashing:
			continue

		var other_start: Vector2 = other.global_position
		var other_end: Vector2 = other.to_global(
			other.laser_target
		)

		var intersection = calculate_segment_intersection(
			start_point,
			end_point,
			other_start,
			other_end
		)

		if intersection == null:
			continue

		var distance := start_point.distance_to(intersection)

		if distance < closest_distance:
			closest_distance = distance
			closest_point = intersection
			closest_laser = other

	if closest_laser == null:
		return []

	return [
		closest_point,
		closest_laser
	]


func calculate_segment_intersection(
	p1: Vector2,
	p2: Vector2,
	p3: Vector2,
	p4: Vector2
):
	var r: Vector2 = p2 - p1
	var s: Vector2 = p4 - p3

	var denominator: float = r.cross(s)

	if abs(denominator) < 0.00001:
		return null

	var qp: Vector2 = p3 - p1

	var t: float = qp.cross(s) / denominator
	var u: float = qp.cross(r) / denominator

	if t < 0.0 or t > 1.0:
		return null

	if u < 0.0 or u > 1.0:
		return null

	return p1 + r * t


func start_beam_clash(
	point: Vector2,
	other_laser: RayCast2D
) -> void:

	if is_clashing:
		return

	if other_laser == null or not other_laser.is_casting:
		return

	is_clashing = true
	clash_point = point
	clashing_laser = other_laser

	line_2d.set_point_position(
		1,
		to_local(point)
	)

	Global.explosion.boom(
		point,
		line_2d.default_color,
		"LaserExplode"
	)

	if other_laser.has_method("join_beam_clash"):
		other_laser.join_beam_clash(
			point,
			self
		)


func join_beam_clash(
	point: Vector2,
	other_laser: RayCast2D
) -> void:

	if is_clashing:
		return

	is_clashing = true
	clash_point = point
	clashing_laser = other_laser

	line_2d.set_point_position(
		1,
		to_local(point)
	)

	Global.explosion.boom(
		point,
		line_2d.default_color,
		"LaserExplode"
	)


func set_is_casting(new_value: bool) -> void:
	if is_casting == new_value:
		return

	is_casting = new_value
	set_physics_process(is_casting)

	if is_casting:
		laser_target = Vector2.ZERO
		damage_timer = 0.0

		is_clashing = false
		clashing_laser = null
		clash_point = Vector2.ZERO

		line_2d.set_point_position(0, Vector2.ZERO)
		line_2d.set_point_position(1, Vector2.ZERO)

		appear()
	else:
		laser_target = Vector2.ZERO
		damage_timer = 0.0

		is_clashing = false
		clashing_laser = null
		clash_point = Vector2.ZERO

		disappear()


func appear() -> void:
	line_2d.visible = true
	line_2d.scale = Vector2.ONE


func disappear() -> void:
	if tween and tween.is_running():
		tween.kill()

	tween = create_tween()

	tween.tween_property(
		line_2d,
		"scale:x",
		0.0,
		GROWTH_TIME
	).from_current()

	tween.tween_callback(line_2d.hide)
