# SPDX-FileCopyrightText: 2026 Tirth Kavathiya <tirthkavathiya@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

extends Node

const ENABLE_ANGULAR_INERTIA = false

var star: Node2D
var explosion: Node2D

func set_star(value: Node2D) -> void:
	star = value
	
func set_explosion(value: Node2D) -> void:
	explosion = value

func _ready() -> void:
	get_viewport().set_use_hdr_2d(true)
