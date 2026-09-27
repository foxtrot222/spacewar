extends RayCast2D

@onready var line_2d: Line2D = $Line2D

const CAST_SPEED := 7000.0
const MAX_LENGTH := 1400.0
const GROWTH_TIME := 0.1
const DAMAGE_TIME := 0.01
const LASER_DAMAGE := 1
const MAX_LASER_TIME := 100.0
const LASER_POINTS := 50.0

var is_casting := false: set = set_is_casting
var tween: Tween = null
var laser_target: Vector2
var damage_timer: float = 0.0
var length
var laser_cooldown := MAX_LASER_TIME
var laser_overheated := false

func _ready() -> void:
	set_is_casting(is_casting)
	line_2d.set_point_position(0, Vector2.ZERO)
	line_2d.set_point_position(1, Vector2.ZERO)
	line_2d.visible = false
	length = MAX_LENGTH

func _physics_process(delta: float) -> void:
	if not is_casting and not laser_overheated:
		laser_cooldown = min(laser_cooldown + LASER_POINTS * delta, MAX_LASER_TIME)
		return
	laser_cooldown = max(laser_cooldown - LASER_POINTS * delta, 0.0)
	if laser_cooldown <= 0.0:
		is_casting = false
		laser_overheated = true
		return

	laser_target.x = move_toward(
		laser_target.x,
		MAX_LENGTH,
		CAST_SPEED * delta
	)
	target_position = laser_target
	force_raycast_update()

	var laser_end_position: Vector2
	if is_colliding():
		var boom_point := get_collision_point()
		
		laser_end_position = to_local(boom_point)
		laser_target = laser_end_position
		target_position = laser_target
		Global.explosion.boom(boom_point, line_2d.default_color, "LaserExplode")
		var collider = get_collider()

		damage_timer += delta
		if damage_timer >= DAMAGE_TIME:
			if collider and collider.has_method("take_damage"):
				collider.take_damage(LASER_DAMAGE)
			damage_timer = 0.0

		if collider:
			if collider.name == "Missile" or collider.name == "Bullet":
				Global.explosion.boom(boom_point, collider.color, collider.name + "Explode")
				collider.queue_free()
	else:
		laser_end_position = laser_target
		damage_timer = 0.0
		
	line_2d.set_point_position(1, laser_end_position)

func set_is_casting(new_value: bool) -> void:
	if is_casting == new_value:
		return
	is_casting = new_value
	
	if is_casting:
		line_2d.set_point_position(0, Vector2.ZERO)
		line_2d.set_point_position(1, Vector2.ZERO)
		damage_timer = 0.0
		appear()
	else:
		
		laser_target = Vector2.ZERO
		disappear()

		

func appear() -> void:
	line_2d.visible = true
	line_2d.scale = Vector2.ONE

func disappear() -> void:
	if tween and tween.is_running():
		tween.kill()
	tween = create_tween()
	tween.tween_property(line_2d, "scale:x", 0.0, GROWTH_TIME).from_current()
	tween.tween_callback(line_2d.hide)
