extends Node2D

const gravity_strength: float = 500000.0
const kill_radius: float = 40.0

# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	Global.gravity_well = self
pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.

func _process(delta: float) -> void:
	pass
