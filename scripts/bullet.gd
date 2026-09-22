extends Area2D

const BULLET_SPEED := 800.0
const MAX_SPEED := 800.0
const BULLET_DAMAGE := 5

var velocity: Vector2
var shooter: CharacterBody2D

func setup(start_position: Vector2, start_direction: Vector2, shooter_player: CharacterBody2D) -> void:
	global_position = start_position
	velocity = start_direction.normalized() * BULLET_SPEED
	rotation = start_direction.angle()
	shooter = shooter_player
	$Line2D.default_color = shooter.color

func _physics_process(delta: float) -> void:
	if velocity.length() > MAX_SPEED:
		velocity = velocity.normalized() * MAX_SPEED
	global_position += velocity * delta
	rotation = velocity.angle()

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		if body == shooter:
			return
		var damage := BULLET_DAMAGE
		print("Bullet hit Player %s! Damage: %s" % [int(body.player_prefix), damage])
		body.take_damage(damage)
		Global.explosion.set_explosion(position, shooter.color, "BulletExplode")
		queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
