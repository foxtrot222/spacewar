extends Node

var gravity_well: Node2D

const ENABLE_ANGULAR_INERTIA = true

const PLAYER_SCENE = preload("res://scenes/player.tscn")
const BULLET_SCENE = preload("res://scenes/bullet.tscn")

func respawn_player(player: CharacterBody2D) -> void:

	if player == null:
		return

	var player_prefix: String = player.player_prefix
	var player_color: Color = player.color
	var spawn_position: Vector2 = player.spawn_position

	player.queue_free()

	await get_tree().create_timer(2.0).timeout

	var new_player := PLAYER_SCENE.instantiate() as CharacterBody2D

	new_player.player_prefix = player_prefix
	new_player.color = player_color
	new_player.spawn_position = spawn_position
	new_player.birth = false
	new_player.ghost = true

	get_tree().current_scene.add_child(new_player)


func spawn_bullet(
	start_position: Vector2,
	start_direction: Vector2,
	shooter_player: CharacterBody2D
) -> void:

	var bullet := BULLET_SCENE.instantiate()

	bullet.setup(
		start_position,
		start_direction,
		shooter_player
	)
	
	get_tree().current_scene.add_child(bullet)
	
func _ready() -> void:
	get_viewport().set_use_hdr_2d(true)
