@tool
extends RayCast2D

## Speed at which the laser extends when first fired, in pixels per second.
@export var cast_speed := 7000.0
## Maximum length of the laser in pixels.
@export var max_length := 1400.0
## Base duration of the tween animation in seconds.
@export var growth_time := 0.1

## If `true`, the laser is firing.
## It plays appearing and disappearing animations when it's not animating.
## See `appear()` and `disappear()` for more information.
@export var is_casting := false: set = set_is_casting

var tween: Tween = null
var laser_target: Vector2
var damage_timer: float = 0.0
var length

@onready var line_2d: Line2D = $Line2D

func _ready() -> void:
	set_is_casting(is_casting)
	
	# Initialize line points: start at start_distance along +X axis
	line_2d.set_point_position(0, Vector2.ZERO)
	line_2d.set_point_position(1, Vector2.ZERO)

	line_2d.visible = false
	
	# Configure raycast length
	length = max_length

func _physics_process(delta: float) -> void:
	if not is_casting:
		return

	# Extend the laser toward max_length
	laser_target.x = move_toward(
		laser_target.x,
		max_length,
		cast_speed * delta
	)

	# Force raycast update and check collisions
	force_raycast_update()

	var laser_end_position: Vector2
	if is_colliding():
		var boom_point = get_collision_point()
		laser_end_position = to_local(get_collision_point())
		Global.explosion.boom(boom_point, line_2d.default_color, "LaserExplode")
		var collider = get_collider()

		# Deal damage to hit object - 1 damage per 10ms (100 dmg/sec)
		damage_timer += delta
		if damage_timer >= 0.01:  # 10ms = 0.01 seconds
			if collider and collider.has_method("take_damage"):
				collider.take_damage(1)  # 1 damage per 10ms
			damage_timer = 0.0

		# Destroy missiles and bullets on contact
		if collider:
			if collider.name == "Missile" or collider.name == "Bullet":
				Global.explosion.boom(boom_point, line_2d.default_color, collider.name + "Explode	")
				collider.queue_free()
	else:
		laser_end_position = laser_target
		damage_timer = 0.0

	# Update visual line endpoint - line points along local +X
	line_2d.set_point_position(1, laser_end_position)

func set_is_casting(new_value: bool) -> void:
	if is_casting == new_value:
		return
	is_casting = new_value
	set_physics_process(is_casting)

	if is_casting:
		line_2d.set_point_position(0, Vector2.ZERO)
		line_2d.set_point_position(1, Vector2.ZERO)
		line_2d.scale = Vector2(0, 1)  # Reset scale for tween animation
		damage_timer = 0.0

		appear()
	else:
		laser_target = Vector2.ZERO
		disappear()

func appear() -> void:
	line_2d.visible = true
	if tween and tween.is_running():
		tween.kill()
	tween = create_tween()
	tween.tween_property(line_2d, "scale:x", 1.0, growth_time * 2.0).from(0.0)

func disappear() -> void:
	if tween and tween.is_running():
		tween.kill()
	tween = create_tween()
	tween.tween_property(line_2d, "scale:x", 0.0, growth_time).from_current()
	tween.tween_callback(line_2d.hide)
