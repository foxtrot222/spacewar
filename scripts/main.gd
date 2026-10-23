extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$HUD1.initialize($Player1)
	$HUD2.initialize($Player2)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
