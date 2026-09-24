extends Node

const PLAYER_SCENE = preload("res://scenes/player.tscn")
const BULLET_SCENE = preload("res://scenes/bullet.tscn")
const MISSILE_SCENE = preload("res://scenes/missile.tscn")

func respawn_player(player: RigidBody2D) -> void:
	if player == null:
		return
	var player_prefix: String = player.player_prefix
	var player_color: Color = player.color
	var spawn_position: Vector2 = player.spawn_position
	Global.explosion.boom(player.position, player_color, "ShipExplode")
	player.queue_free()

	await get_tree().create_timer(2.0).timeout
	
	var new_player := PLAYER_SCENE.instantiate() as RigidBody2D
	new_player.player_prefix = player_prefix
	new_player.color = player_color
	new_player.spawn_position = spawn_position
	new_player.health = new_player.MAX_HEALTH
	new_player.birth = false
	new_player.ghost = true
	
	get_tree().current_scene.add_child(new_player)

func spawn_bullet(
	start_position: Vector2,
	start_direction: Vector2,
	shooter_player: RigidBody2D
) -> void:
	var bullet := BULLET_SCENE.instantiate()
	bullet.setup(start_position, start_direction, shooter_player)
	get_tree().current_scene.add_child(bullet)

func spawn_missile(
	start_position: Vector2,
	start_direction: Vector2,
	shooter_player: RigidBody2D
) -> void:
	var missile := MISSILE_SCENE.instantiate()
	missile.setup(start_position, start_direction, shooter_player)
	get_tree().current_scene.add_child(missile)
