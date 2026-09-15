extends Area2D

const BULLET_SPEED := 800.0
const MAX_SPEED := 800.0

# Damage constants - torpedo does 50, bullet does 10
const BULLET_DAMAGE := 5

# No slots counter - torpedos/bullets have unlimited fire with cooldown handled by player

var velocity: Vector2
var shooter: CharacterBody2D

func setup(
	start_position: Vector2,
	start_direction: Vector2,
	shooter_player: CharacterBody2D
) -> void:
	global_position = start_position
	velocity = start_direction.normalized() * BULLET_SPEED
	rotation = start_direction.angle()
	shooter = shooter_player

func _physics_process(delta: float) -> void:

	# Gravity
	var direction_to_star = global_position
	var distance = max(direction_to_star.length(), 30.0)

	var gravity_force = direction_to_star.normalized() * (Global.gravity_well.GRAVITY_STRENGTH / (distance * distance))
	velocity += gravity_force * delta

	# Maximum speed
	if velocity.length() > MAX_SPEED:
		velocity = velocity.normalized() * MAX_SPEED

	# Move torpedo/bullet
	global_position += velocity * delta

	# Rotate toward movement direction
	rotation = velocity.angle()

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		if body == shooter:
			return

		var damage := BULLET_DAMAGE
		print("Bullet hit Player " + str(int(body.player_prefix)) + "! Damage: " + str(damage))

		# Apply damage to player
		body.take_damage(damage)
		queue_free()
