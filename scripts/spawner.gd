# SPDX-FileCopyrightText: 2026 Tirth Kavathiya <tirthkavathiya@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

extends Node

signal player_respawned(player: RigidBody2D)

const PLAYER_SCENE = preload("res://scenes/player.tscn")
const BULLET_SCENE = preload("res://scenes/bullet.tscn")
const MISSILE_SCENE = preload("res://scenes/missile.tscn")

func respawn_player(player: RigidBody2D) -> void:
	if player == null:
		return
	var player_prefix: String = player.player_prefix
	var player_color: Color = player.color
	var hud : Control = player.hud
	Global.explosion.boom(player.position, player_color, "ShipExplode")
	SoundManager.thrust(int(player_prefix), -1)
	player.queue_free()

	await get_tree().create_timer(2.0).timeout
	
	var new_player := PLAYER_SCENE.instantiate() as RigidBody2D
	new_player.player_prefix = player_prefix
	new_player.color = player_color
	new_player.health = new_player.MAX_HEALTH
	new_player.birth = false
	new_player.ghost = true
	new_player.hud = hud
	new_player.position = Global.randcc(200.0)
	new_player.rotation = randf_range(0.0, TAU)
	get_tree().current_scene.add_child(new_player)
	
	player_respawned.emit(new_player)

func spawn_bullet(start_position: Vector2, start_direction: Vector2, color : Color) -> void:
	var bullet := BULLET_SCENE.instantiate()
	bullet.setup(start_position, start_direction, color)
	get_tree().current_scene.add_child(bullet)

func spawn_missile(target : RigidBody2D, start_position: Vector2, start_direction: Vector2, color : Color) -> void:
	var missile := MISSILE_SCENE.instantiate()
	missile.setup(target, start_position, start_direction, color)
	get_tree().current_scene.add_child(missile)
