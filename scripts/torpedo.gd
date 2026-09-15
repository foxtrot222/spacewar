extends Area2D

const TORPEDO_SPEED := 500.0
const TORPEDO_LIFETIME := 5.0
const TORPEDO_DAMAGE := 50

var velocity: Vector2
var shooter: CharacterBody2D
var life_timer: Timer

func _ready() -> void:
	life_timer = $LifeTimer
	life_timer.timeout.connect(queue_free)

func setup(
	start_position: Vector2,
	start_direction: Vector2,
	shooter_player: CharacterBody2D
) -> void:
	global_position = start_position
	velocity = start_direction.normalized() * TORPEDO_SPEED
	rotation = start_direction.angle()
	shooter = shooter_player
	life_timer.start()

func _physics_process(delta: float) -> void:
	# Gravity
	var direction_to_star = Global.gravity_well.global_position - global_position
	var distance = max(direction_to_star.length(), 30.0)
	var gravity_force = direction_to_star.normalized() * (Global.gravity_well.GRAVITY_STRENGTH / (distance * distance))
	velocity += gravity_force * delta

	# Move torpedo
	global_position += velocity * delta

	# Rotate toward movement direction
	rotation = velocity.angle()

	if global_position.distance_to(Global.gravity_well.global_position) > 1500:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		if body == shooter:
			return

		# Deal torpedo damage
		body.take_damage(TORPEDO_DAMAGE)
		print("Torpedo hit Player " + str(int(body.player_prefix)) + "! Damage: " + str(TORPEDO_DAMAGE))
		queue_free()

func _on_life_timer_timeout() -> void:
	queue_free()
