# SPDX-FileCopyrightText: 2026 Tirth Kavathiya <tirthkavathiya@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

extends Node

const PLAYERS = 3
const ENABLE_ANGULAR_INERTIA = false

var star: Node2D
var explosion: Node2D

func set_star(value: Node2D) -> void:
	star = value
	
func set_explosion(value: Node2D) -> void:
	explosion = value

func _ready() -> void:
	get_viewport().set_use_hdr_2d(true)

func randcc(size: float) -> Vector2:
	var frame := 1024.0
	var center := Vector2.ONE * (frame / 2.0)
	var radius_sq := size * size
	while true:
		var value := Vector2(randf_range(0.0, frame),randf_range(0.0, frame))
		if (value - center).length_squared() > radius_sq:
			return value
	return Vector2.ZERO
	
	
	
