extends Node2D

const GRAVITY_STRENGTH: float = 0.0
const ROTATE_FACTOR := 5

func _ready() -> void:
	Global.set_star(self)
	add_to_group("star")

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is RigidBody2D:
		body.take_damage(1000)

func _process(delta: float) -> void:
	$Sprite2D.rotate(deg_to_rad(ROTATE_FACTOR) * delta)
