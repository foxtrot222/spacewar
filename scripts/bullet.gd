extends Area2D

const BULLET_SPEED := 800.0
const MAX_SPEED := 800.0
const BULLET_DAMAGE := 5

var velocity: Vector2
var shooter: RigidBody2D

func setup(start_position: Vector2, start_direction: Vector2, shooter_player: RigidBody2D) -> void:
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
	if body is RigidBody2D:
		if body == shooter:
			return
		var damage := BULLET_DAMAGE
		print("Bullet hit Player %s! Damage: %s" % [int(body.player_prefix), damage])
		body.take_damage(damage)
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	# Check if it's the star - bullets destroyed by star
	if area.get_parent().name == "Star" or area.name == "Star":
		queue_free()
		return
	# Check if it's a missile - bullets don't destroy missiles
	if area.name == "Missile":
		return  # Don't destroy missile, bullet passes through
	# Check if it's another bullet - bullets pass through each other
	if area.name == "Bullet":
		return  # Don't destroy other bullets

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
