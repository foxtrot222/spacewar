# SPDX-FileCopyrightText: 2026 Tirth Kavathiya <tirthkavathiya@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

extends Control

@export var color : Color
@onready var player : RigidBody2D

var max_laser := 0.0
var max_health := 0.0
var missiles : Array[ColorRect]

var back := 0.118
var front :=  0.784

func _ready() -> void:
	missiles.resize(4)

func _process(delta: float) -> void:
	if not is_instance_valid(player):
		visible = false
		return
	visible = not player.ghost
	$HealthBar.size.x = scale(player.health, 0.0, 128.0, max_health)
	$LaserBar.size.x = scale(player.laser.laser_cooldown, 0.0, 64.0, max_laser)
	$QJ.modulate.a = front if player.qj_cooldown else back
	$Target.modulate.a = front if player.target != null else back
	match player.equipped_weapon:
		player.Weapon.BULLET:
			$Bullet.modulate.a = front
			$Laser.modulate.a = back
			$HMissile.modulate.a = back
		player.Weapon.MISSILE:
			$HMissile.modulate.a = front
			$Bullet.modulate.a = back
			$Laser.modulate.a = back
		player.Weapon.LASER:
			$Laser.modulate.a = front
			$Bullet.modulate.a = back
			$HMissile.modulate.a = back
	for i in missiles.size():
		missiles[i].modulate.a = ( front if i < player.missile_slots else back )

func initialize(p : RigidBody2D):
	player = p
	player.hud = self
	color = player.color
	var j = 0
	for i in get_children():
		i.modulate = Color(color.r, color.g, color.b, i.modulate.a)
		if i.name.begins_with("Missile"):
			missiles[j] = i
			j += 1
	max_laser = player.laser.MAX_LASER_TIME
	max_health = player.MAX_HEALTH

func scale(x : float, a : float, b : float, max : float) -> float:
	return a + ( x * (b - a) ) / max
