extends Node2D

const GRAVITY_STRENGTH: float = 500000.0

func _ready() -> void:
	# Register this gravity well globally
	Global.set_gravity_well(self)
	# Add to star group for group-based checks (is_in_group("star"))
	add_to_group("star")

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		# Kill the player instantly when entering the star - use take_damage with high amount
		body.take_damage(1000)  # Instant kill via player health system
