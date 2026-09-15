extends Node

# Global game settings - shared constants
const ENABLE_ANGULAR_INERTIA = false

# Scene references (autoload for easy access)
const PLAYER_SCENE = preload("res://scenes/player.tscn")
const BULLET_SCENE = preload("res://scenes/bullet.tscn")
const MISSILE_SCENE = preload("res://scenes/missile.tscn")

var gravity_well: Node2D

#func _ready() -> void:
#

#func _register_missile_input(action_name: StringName, physical_keycode: int) -> void:
#\t#if not InputMap.has_action(action_name):
#\t\t#InputMap.add_action(action_name)
#

#\t#var event := InputEventKey.new()
#\t#event.physical_keycode = physical_keycode
#\t#InputMap.action_add_event(action_name, event)

func set_gravity_well(value: Node2D) -> void:
\tgravity_well = value

func respawn_player(player: CharacterBody2D) -> void:
\tif player == null:
\t\treturn

\tvar player_prefix: String = player.player_prefix
\tvar player_texture: Texture2D = player.texture
\tvar spawn_position: Vector2 = player.spawn_position

\tplayer.queue_free()

\tawait get_tree().create_timer(2.0).timeout

\tvar new_player := PLAYER_SCENE.instantiate() as CharacterBody2D

\tnew_player.player_prefix = player_prefix
\tnew_player.texture = player_texture
\tnew_player.spawn_position = spawn_position
\tnew_player.health = new_player.MAX_HEALTH
\tnew_player.birth = false
\tnew_player.ghost = true

\tget_tree().current_scene.add_child(new_player)


func spawn_bullet(
\tstart_position: Vector2,
\tstart_direction: Vector2,
\tshooter_player: CharacterBody2D
) -> void:
\tvar bullet := BULLET_SCENE.instantiate()
\tbullet.setup(start_position, start_direction, shooter_player)
\tget_tree().current_scene.add_child(bullet)

func spawn_missile(
\tstart_position: Vector2,
\tstart_direction: Vector2,
\tshooter_player: CharacterBody2D
) -> void:
\tvar missile := MISSILE_SCENE.instantiate()
\tmissile.set_script(load("res://scripts/missile.gd"))
\tmissile.body_entered.connect(missile._on_body_entered)
\tget_tree().current_scene.add_child(missile)
\tmissile.setup(start_position, start_direction, shooter_player)