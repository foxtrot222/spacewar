# SPDX-FileCopyrightText: 2026 Tirth Kavathiya <tirthkavathiya@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

extends Area2D

const MISSILE_SPEED := 150.0
const MISSILE_DAMAGE := 50
const STEER_FORCE := 10000.0

var velocity: Vector2
var shooter: RigidBody2D
var color : Color
var target : RigidBody2D = null
var acceleration := Vector2.ZERO

func setup(t : RigidBody2D, start_position: Vector2, start_direction: Vector2, col : Color) -> void:
	global_position = start_position
	velocity = start_direction.normalized() * MISSILE_SPEED
	rotation = start_direction.angle()
	color = col
	$TailLine2D.default_color = color
	target = t

func _physics_process(delta: float) -> void:
	if is_instance_valid(target) and target:
		acceleration += (seek() + safe()) * delta
	velocity += acceleration * delta
	velocity = velocity.limit_length(MISSILE_SPEED)
	rotation = velocity.angle()
	global_position += velocity * delta
	
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

func seek():
	var steer = Vector2.ZERO
	var desired = (target.position - position).normalized() * MISSILE_SPEED
	steer = ( desired - velocity ).normalized() * STEER_FORCE
	return steer

func safe():
	var center = Global.star.position
	var radius = 200.0
	var dist = position - center
	if dist.length_squared() < radius * radius:
		return dist.normalized() * STEER_FORCE
	return Vector2.ZERO
