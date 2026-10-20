extends Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func qj():
	$QJ.play()

func fire_bullet():
	$FireBullet.play()
	
func fire_missile():
	$FireMissile.play()
	
func sound():
	$Sound.play()
