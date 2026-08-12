extends Node2D

const GRAVITY_STRENGTH: float = 500000.0


func _ready() -> void:

	# Register this gravity well globally
	Global.gravity_well = self


func _on_area_2d_body_entered(body: Node2D) -> void:

	if body is CharacterBody2D:

		print("Player entered the star!")

		Global.respawn_player(body)
