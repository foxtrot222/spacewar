# SPDX-FileCopyrightText: 2026 Tirth Kavathiya <tirthkavathiya@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

extends Node

func qj():
	$QJ.play()

func fire_bullet():
	$FireBullet.play()
	
func fire_missile():
	$FireMissile.play()
	
func sound():
	$Sound.play()
	
func boom(expsn : String):
	get_node(expsn).play()
