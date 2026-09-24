extends Area2D

const MISSILE_SPEED := 150.0
const MISSILE_LIFETIME := 5.0
const MISSILE_DAMAGE := 50

var velocity: Vector2
var shooter: RigidBody2D

func setup(start_position: Vector2, start_direction: Vector2, shooter_player: RigidBody2D) -> void:
	global_position = start_position
	velocity = start_direction.normalized() * MISSILE_SPEED
	rotation = start_direction.angle()
	shooter = shooter_player
	$TailLine2D.default_color = shooter.color

func _physics_process(delta: float) -> void:
	var direction_to_star = Global.star.global_position - global_position
	var distance = max(direction_to_star.length(), 30.0)
	var gravity_force = direction_to_star.normalized() * (Global.star.GRAVITY_STRENGTH / (distance * distance))
	velocity += gravity_force * delta
	global_position += velocity * delta
	rotation = velocity.angle()

func _on_body_entered(body: Node2D) -> void:
	if body is RigidBody2D:
		if body == shooter:
			return
		body.take_damage(MISSILE_DAMAGE)
		print("Missile hit Player %s! Damage: %s" % [int(body.player_prefix), MISSILE_DAMAGE])
		queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
