extends Node

# Global game settings - shared constants
const ENABLE_ANGULAR_INERTIA = false

# Scene references (autoload for easy access)
const PLAYER_SCENE = preload("res://scenes/player.tscn")
const BULLET_SCENE = preload("res://scenes/bullet.tscn")
const TORPEDO_SCENE = preload("res://scenes/torpedo.tscn")

var gravity_well: Node2D

#func _ready() -> void:
#
#func _register_torpedo_input(action_name: StringName, physical_keycode: int) -> void:
	#if not InputMap.has_action(action_name):
		#InputMap.add_action(action_name)
#
	#var event := InputEventKey.new()
	#event.physical_keycode = physical_keycode
	#InputMap.action_add_event(action_name, event)

func set_gravity_well(value: Node2D) -> void:
	gravity_well = value

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
	new_player.health = new_player.MAX_HEALTH
	new_player.birth = false
	new_player.ghost = true

	get_tree().current_scene.add_child(new_player)


func spawn_bullet(
	start_position: Vector2,
	start_direction: Vector2,
	shooter_player: CharacterBody2D
) -> void:
	var bullet := BULLET_SCENE.instantiate()
	bullet.setup(start_position, start_direction, shooter_player)
	get_tree().current_scene.add_child(bullet)

func spawn_torpedo(
	start_position: Vector2,
	start_direction: Vector2,
	shooter_player: CharacterBody2D
) -> void:
	var torpedo := TORPEDO_SCENE.instantiate()
	torpedo.set_script(load("res://scripts/torpedo.gd"))
	torpedo.body_entered.connect(torpedo._on_body_entered)
	get_tree().current_scene.add_child(torpedo)
	torpedo.setup(start_position, start_direction, shooter_player)
