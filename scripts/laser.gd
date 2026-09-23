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
@onready var laser_collision: Area2D = $LaserCollision
@onready var collision_shape: CollisionShape2D = $LaserCollision/CollisionShape2D

func _ready() -> void:
	set_is_casting(is_casting)
	
	# Initialize line points: start at start_distance along +X axis
	line_2d.set_point_position(0, Vector2.ZERO)
	line_2d.set_point_position(1, Vector2.ZERO)
	
	line_2d.visible = false
	
	# Configure raycast target position
	target_position = Vector2.ZERO
	
	# Add LaserCollision as exception so raycast doesn't hit itself
	add_exception(laser_collision)
	
	# Connect area_entered signal for laser vs laser collision
	laser_collision.area_entered.connect(_on_laser_collision_area_entered)

func _physics_process(delta: float) -> void:
	if not is_casting:
		return

	# Extend the laser toward max_length
	laser_target.x = move_toward(
		laser_target.x,
		max_length,
		cast_speed * delta
	)

	# Update raycast target position
	target_position = laser_target

	# Update collision segment shape - from origin to laser_target
	var segment_shape: SegmentShape2D = collision_shape.shape
	segment_shape.a = Vector2.ZERO
	segment_shape.b = laser_target

	# Scale visual line to match laser extension (0 to 1)
	line_2d.scale = Vector2(laser_target.x / max_length, 1.0)

	# Force raycast update and check collisions
	force_raycast_update()

	var laser_end_position: Vector2
	if is_colliding():
		laser_end_position = to_local(get_collision_point())
		
		# Deal damage to hit object - 1 damage per 10ms (100 dmg/sec)
		damage_timer += delta
		if damage_timer >= 0.01:  # 10ms = 0.01 seconds
			var collider = get_collider()
			if collider and collider.has_method("take_damage"):
				collider.take_damage(1)  # 1 damage per 10ms
			damage_timer = 0.0
		
		# Check what we hit and destroy accordingly
		var collider = get_collider()
		if collider:
			print("Laser hit: ", collider.name, " (type: ", collider.get_class(), ")")
			# Check if it's a missile - laser destroys missile, line cuts here
			if collider.name == "Missile":
				collider.queue_free()
			# Check if it's a bullet - laser destroys bullet, line cuts here
			elif collider.name == "Bullet":
				collider.queue_free()
			# Check if it's another laser's collision area - cut both lasers at meeting point
			elif collider.name == "LaserCollision":
				var other_laser = collider.get_parent()
				if other_laser.name == "Laser":
					print("Laser vs Laser collision at meeting point!")
					# Cut this laser's line at collision point (already set in laser_end_position)
					# Destroy the other laser
					other_laser.queue_free()
					# Destroy this laser
					queue_free()
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
		line_2d.scale = Vector2(0, 1)
		line_2d.visible = true
		damage_timer = 0.0
		laser_target = Vector2.ZERO
		target_position = Vector2.ZERO
	else:
		laser_target = Vector2.ZERO
		target_position = Vector2.ZERO
		line_2d.visible = false

func _on_laser_collision_area_entered(area: Area2D) -> void:
	# Check if the colliding area is from another laser
	if area.get_parent().name == "Laser":
		print("Laser collision with another laser!")
		# Destroy the other laser
		area.get_parent().queue_free()
		# Destroy this laser
		queue_free()
