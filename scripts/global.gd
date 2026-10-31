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
	var frame := get_viewport().get_visible_rect().size
	var center := star.global_position if star else frame / 2.0
	var radius := size * size
	var margin := 200.0
	for _i in 64:
		var p := Vector2(randf_range(margin, frame.x - margin),randf_range(margin, frame.y - margin))
		if p.distance_squared_to(center) > radius:
			return p
	var a := randf_range(0.0, TAU)
	return ( center + Vector2.RIGHT.rotated(a) * size ).clamp(Vector2(margin, margin), frame - Vector2(margin, margin))
