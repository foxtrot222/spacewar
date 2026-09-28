extends Node2D

func _ready() -> void:
	Global.set_explosion(self)

func boom(pos: Vector2, color : Color, expsn : String) -> void:
	var tmp = get_node(expsn)
	var candidate = tmp.duplicate()
	add_child(candidate)
	candidate.position = pos
	candidate.process_material = candidate.process_material.duplicate()
	candidate.process_material.color = color
	candidate.restart()
	candidate.finished.connect(candidate.queue_free)
