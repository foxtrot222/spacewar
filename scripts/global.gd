extends Node

var gravity_well: Node2D

const PLAYER_SCENE = preload("res://scenes/player.tscn")

# Collision layer used only while the player is a ghost
const GHOST_LAYER := 4


func respawn_player(player: CharacterBody2D) -> void:

	if player == null:
		return

	var player_prefix: String = player.player_prefix
	var player_texture: Texture2D = player.texture
	var spawn_position: Vector2 = player.spawn_marker.global_position
	var new_spawn_marker: Marker2D = player.spawn_marker

	player.queue_free()

	await get_tree().create_timer(2.0).timeout

	var new_player := PLAYER_SCENE.instantiate() as CharacterBody2D

	new_player.player_prefix = player_prefix
	new_player.texture = player_texture
	new_player.spawn_marker = new_spawn_marker

	get_tree().current_scene.add_child(new_player)

	new_player.global_position = spawn_position

	# =========================================================
	# GHOST MODE
	# =========================================================

	# Save normal collision settings
	var normal_layer := new_player.collision_layer
	var normal_mask := new_player.collision_mask

	# Put player on ghost layer
	new_player.collision_layer = 1 << (GHOST_LAYER - 1)

	# Ghost does not detect anything
	new_player.collision_mask = 0

	# Make player transparent
	new_player.get_node("Sprite2D").modulate.a = 0.35


	# Wait 5 seconds
	await get_tree().create_timer(5.0).timeout


	# =========================================================
	# RESTORE NORMAL MODE
	# =========================================================

	new_player.collision_layer = normal_layer
	new_player.collision_mask = normal_mask

	# Restore appearance
	new_player.get_node("Sprite2D").modulate.a = 1.0
