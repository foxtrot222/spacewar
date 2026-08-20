extends Area2D

const TORPEDO_SPEED := 500.0
const MAX_SPEED := 800.0

var velocity: Vector2
var shooter: CharacterBody2D

func setup(
	start_position: Vector2,
	start_direction: Vector2,
	shooter_player: CharacterBody2D
) -> void:
	global_position = start_position
	velocity = start_direction.normalized() * TORPEDO_SPEED
	rotation = start_direction.angle()
	shooter = shooter_player

func _physics_process(delta: float) -> void:

	# Gravity
	var direction_to_star = Global.gravity_well.global_position - global_position
	var distance = max(direction_to_star.length(), 30.0)

	var gravity_force = direction_to_star.normalized() * (
		Global.gravity_well.GRAVITY_STRENGTH / (distance * distance)
	)

	velocity += gravity_force * delta

	# Maximum speed
	if velocity.length() > MAX_SPEED:
		velocity = velocity.normalized() * MAX_SPEED

	# Move torpedo
	global_position += velocity * delta

	# Rotate toward movement direction
	rotation = velocity.angle()

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:

		if body == shooter:
			return

		print("Torpedo hit player!")
		body.queue_free()
		queue_free()
		Global.respawn_player(body)
		
		
		if is_instance_valid(shooter):
			shooter.increment_slot()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	if is_instance_valid(shooter):
		shooter.increment_slot()
	queue_free()

func _on_life_timer_timeout() -> void:
	if is_instance_valid(shooter):
		shooter.increment_slot()
	queue_free()
