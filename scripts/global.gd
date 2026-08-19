extends Node

var gravity_well: Node2D

const PLAYER_SCENE = preload("res://scenes/player.tscn")
const TORPEDO_SCENE = preload("res://scenes/torpedo.tscn")


func respawn_player(player: CharacterBody2D) -> void:

	if player == null:
		return

	var player_prefix: String = player.player_prefix
	var player_texture: Texture2D = player.texture
	var spawn_position: Vector2 = player.spawn_position

	player.queue_free()

	await get_tree().create_timer(2.0).timeout

	var new_player := PLAYER_SCENE.instantiate() as CharacterBody2D

	new_player.player_prefix = player_prefix
	new_player.texture = player_texture
	new_player.spawn_position = spawn_position
	new_player.birth = false

	get_tree().current_scene.add_child(new_player)


func spawn_torpedo(
	start_position: Vector2,
	start_direction: Vector2,
	shooter_prefix: String
) -> void:

	var torpedo := TORPEDO_SCENE.instantiate()

	torpedo.setup(
		start_position,
		start_direction,
		shooter_prefix
	)
	
	get_tree().current_scene.add_child(torpedo)
