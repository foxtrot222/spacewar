extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.set_explosion(self)

func set_explosion(pos: Vector2, color : Color, expsn : String) -> void:
	var tmp = get_node(expsn)
	var candidate = tmp.duplicate()
	add_child(candidate)
	candidate.position = pos
	candidate.process_material = candidate.process_material.duplicate()
	candidate.process_material.color = color
	candidate.restart()
	candidate.finished.connect(candidate.queue_free)
