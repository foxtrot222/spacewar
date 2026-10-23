# SPDX-FileCopyrightText: 2026 Tirth Kavathiya <tirthkavathiya@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

extends Control

@export var color : Color
@onready var player : RigidBody2D

var max_laser := 0.0
var max_health := 0.0
var missiles : Array[ColorRect]

func _ready() -> void:
	missiles.resize(6)

func _process(delta: float) -> void:
	if not is_instance_valid(player):
		visible = false
		return
	visible = not player.ghost
	$HealthBar.size.x = scale(player.health, 0.0, 104.0, max_health)
	$LaserBar.size.x = scale(player.laser.laser_cooldown, 0.0, 48.0, max_laser)
	$QJBar.modulate.a = float(player.qj_cooldown) * 0.392
	for i in missiles.size():
		missiles[i].modulate.a = ( 0.5882353 if i < player.missile_slots else 0.0 )

func initialize(p : RigidBody2D):
	player = p
	player.hud = self
	color = player.color
	var j = 0
	for i in get_children():
		i.color = color
		if i.name.begins_with("Missile"):
			missiles[j] = i
			j += 1
	max_laser = player.laser.MAX_LASER_TIME
	max_health = player.MAX_HEALTH

func scale(x : float, a : float, b : float, max : float) -> float:
	return a + ( x * (b - a) ) / max
