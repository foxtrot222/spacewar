extends Area2D

const MISSILE_SPEED := 150.0
const MISSILE_LIFETIME := 5.0
const MISSILE_DAMAGE := 50

var velocity: Vector2
var shooter: RigidBody2D
var color : Color

func setup(start_position: Vector2, start_direction: Vector2, col : Color) -> void:
	global_position = start_position
	velocity = start_direction.normalized() * MISSILE_SPEED
	rotation = start_direction.angle()
	color = col
	$TailLine2D.default_color = color

func _physics_process(delta: float) -> void:
	var direction_to_star = Global.star.global_position - global_position
	var distance = max(direction_to_star.length(), 30.0)
	var gravity_force = direction_to_star.normalized() * (Global.star.GRAVITY_STRENGTH / (distance * distance))
	velocity += gravity_force * delta
	global_position += velocity * delta
	rotation = velocity.angle()

func _on_area_entered(area: Area2D) -> void:
	var pos = position
	if $ShapeCast2D.get_collision_count():
		pos = $ShapeCast2D.get_collision_point(0)
	if area.name == "KillZone":
		Global.explosion.boom(pos, color, "MissileExplode")
		queue_free()
	if area.name == "Bullet":
		Global.explosion.boom(pos, color, "BulletExplode")
		area.queue_free()
	elif area.name == "Missile":
		Global.explosion.boom(pos, color, "MissileExplode")
		Global.explosion.boom(pos, area.color, "MissileExplode")
		area.queue_free()
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body is RigidBody2D:
		if body.color == color:
			return
		body.take_damage(MISSILE_DAMAGE)
		print("Missile hit Player %s! Damage: %s" % [int(body.player_prefix), MISSILE_DAMAGE])
		var pos = position
		if $ShapeCast2D.get_collision_count():
			pos = $ShapeCast2D.get_collision_point(0)
		Global.explosion.boom(pos, color, "MissileExplode")
		queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
