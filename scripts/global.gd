extends Node

const ENABLE_ANGULAR_INERTIA = false

var gravity_well: Node2D

func set_gravity_well(value: Node2D) -> void:
	gravity_well = value

func _ready() -> void:
	get_viewport().set_use_hdr_2d(true)
