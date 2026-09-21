extends Node

const ENABLE_ANGULAR_INERTIA = false

var star: Node2D

func set_star(value: Node2D) -> void:
	star = value

func _ready() -> void:
	get_viewport().set_use_hdr_2d(true)
