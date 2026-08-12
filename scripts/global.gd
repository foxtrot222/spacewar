extends Node

# Reference to the gravity well
var gravity_well: Node2D

# Player scene used for respawning
const PLAYER_SCENE = preload("res://scenes/player.tscn")


func respawn_player(player: CharacterBody2D) -> void:

	if player == null:
		return

	# Save player properties BEFORE queue_free()
	var player_prefix: String = player.player_prefix
	var player_texture: Texture2D = player.texture

	# Default to the player's current position
	var spawn_position: Vector2 = player.spawn_marker.global_position
	var new_spawn_marker: Marker2D = player.spawn_marker

	# Delete the old player
	player.queue_free()

	# Wait before respawning
	await get_tree().create_timer(2.0).timeout

	# Create a new player
	var new_player := PLAYER_SCENE.instantiate() as CharacterBody2D

	# Restore player properties
	new_player.player_prefix = player_prefix
	new_player.texture = player_texture
	new_player.spawn_marker = new_spawn_marker
	
	# Add the new player to the main scene
	get_tree().current_scene.add_child(new_player)

	# Move the new player to its spawn position
	new_player.global_position = spawn_position

	print("Player respawned:", player_prefix)
	print("Respawn position:", spawn_position)
