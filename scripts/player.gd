extends CharacterBody2D

@export var player_prefix : String
@export var texture : Texture2D

const THRUST := 100.0
const REVERSE_THRUST := 70.0
const ROTATION_SPEED := 30.0
const MAX_SPEED := 800.0
const WRAP_MARGIN := 40.0
const QUANTUM_JUMP_OFFSET := 100
const VELOCITY_RETENTION := 0.5
var screen_size: Vector2


func _ready():
	screen_size = get_viewport_rect().size
	$Sprite2D.texture = texture

func _physics_process(delta: float) -> void:
	
	if Input.is_action_pressed("rotate_left" + player_prefix):
		rotation_degrees -= ROTATION_SPEED * delta
	if Input.is_action_pressed("rotate_right" + player_prefix):
		rotation_degrees += ROTATION_SPEED * delta

	var forward = Vector2.UP.rotated(rotation)
	if Input.is_action_pressed("forward_thrust" + player_prefix):
		velocity += forward * THRUST * delta

	if Input.is_action_just_pressed("quantum_jump"+player_prefix):
		quantum_jump()

	if velocity.length() > MAX_SPEED:
		velocity = velocity.normalized() * MAX_SPEED

	move_and_slide()
	
func _on_visible_on_screen_notifier_2d_screen_exited():
	global_position.x = wrapf(global_position.x,WRAP_MARGIN,screen_size.x)
	global_position.y = wrapf(global_position.y,-WRAP_MARGIN,screen_size.y)

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
