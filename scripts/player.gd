extends CharacterBody2D

@export var player_prefix : String
@export var texture : Texture2D
@export var spawn_position : Vector2

const THRUST := 100.0
const ROTATION_SPEED := 30.0
const MAX_SPEED := 800.0
const WRAP_MARGIN := 40.0
const QUANTUM_JUMP_OFFSET := 100
const VELOCITY_RETENTION := 0.5
const ANGULAR_ACCELERATION := 120.0
const MAX_ANGULAR_SPEED := 180.0

var angular_velocity := 0.0
var screen_size: Vector2
var birth := true
var qj_cooldown := true

func _ready() -> void:
	screen_size = get_viewport_rect().size
	$Sprite2D.texture = texture
	global_position = spawn_position
	if birth:
		$GhostTimer.timeout.emit()

	
func _physics_process(delta: float) -> void:

	# Gravity
	var direction = Global.gravity_well.global_position - global_position
	var distance = max(direction.length(), 30.0)

	var gravity_force = direction.normalized() * (
		Global.gravity_well.GRAVITY_STRENGTH / (distance * distance)
	)

	velocity += gravity_force * delta

	# Rotation
	if Input.is_action_pressed("rotate_left" + player_prefix):
		angular_velocity -= ANGULAR_ACCELERATION * delta

	if Input.is_action_pressed("rotate_right" + player_prefix):
		angular_velocity += ANGULAR_ACCELERATION * delta
		
	if Input.is_action_just_pressed("torpedo" + player_prefix):
		fire_torpedo()
	# Limit rotational speed
	angular_velocity = clamp(
		angular_velocity,
		-MAX_ANGULAR_SPEED,
		MAX_ANGULAR_SPEED
	)

	# Apply rotation
	rotation_degrees += angular_velocity * delta

	# Thrust
	var forward = Vector2.UP.rotated(rotation)

	if Input.is_action_pressed("forward_thrust" + player_prefix ):
		velocity += forward * THRUST * delta

	if Input.is_action_just_pressed("quantum_jump" + player_prefix ):
		if qj_cooldown:
			quantum_jump()
			qj_cooldown=false
			$QJCooldown.start()

	# Maximum speed
	if velocity.length() > MAX_SPEED:
		velocity = velocity.normalized() * MAX_SPEED

	move_and_slide()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:

	if global_position.x < 0:
		global_position.x = screen_size.x
	elif global_position.x > screen_size.x:
		global_position.x = 0

	if global_position.y < 0:
		global_position.y = screen_size.y
	elif global_position.y > screen_size.y:
		global_position.y = 0
func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		print("Torpedo hit player!")
		body.queue_free()
		queue_free()
func quantum_jump():
	var random_position = Vector2(
		randf_range(0, screen_size.x),
		randf_range(0, screen_size.y)
	)
	
	if velocity.length() > 0:
		random_position += velocity.normalized() * QUANTUM_JUMP_OFFSET

	global_position = random_position

	# Reduce momentum after teleport
	velocity *= VELOCITY_RETENTION
func fire_torpedo() -> void:
	var forward := Vector2.UP.rotated(rotation)

	Global.spawn_torpedo(
		global_position + forward * 30.0,
		forward,
		player_prefix
	)
func _on_ghost_timer_timeout() -> void:
	$Sprite2D.modulate.a = 1.0
	collision_layer = 1
	collision_mask = 3


func _on_qj_cool_down_timeout() -> void:
	qj_cooldown=true
