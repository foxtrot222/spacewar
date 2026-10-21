# SPDX-FileCopyrightText: 2026 Tirth Kavathiya <tirthkavathiya@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

extends Node
var thrust_mode: Array[int]

func _ready() -> void:
	thrust_mode.resize(Global.PLAYERS)
	thrust_mode.fill(0)
	
func qj():
	$QJ.play()

func fire_bullet():
	$FireBullet.play()
	
func fire_missile():
	$FireMissile.play()
	
func ghost():
	$Ghost.play()
	
func sound():
	$Sound.play()

func collision():
	$Collision.play()
	
func boom(expsn : String):
	get_node(expsn).play()

func thrust(player : int, mode : int):
	if mode == 0 && thrust_mode[player] == 0:
		$StartThrust.play()
		$Thrust.play()
		thrust_mode[player] = 1
	if mode == 1 && thrust_mode[player] == 1:
		$Thrust.stop()
		$EndThrust.play()
		thrust_mode[player] = 0
	if mode == -1:
		$Thrust.stop()
		thrust_mode[player] = 0
