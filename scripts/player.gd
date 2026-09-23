extends CharacterBody2D

@export var player_prefix : String
@export var color : Color
@export var spawn_position : Vector2

@onready var laser = $Laser
@onready var thruster1 = $Thruster1
@onready var thruster2 = $Thruster2

const MAX_HEALTH := 100
var health := MAX_HEALTH

const THRUST := 100.0
const MAX_SPEED := 800.0
const ROTATION_SPEED := 60.0
const ANGULAR_ACCELERATION := 120.0
const MAX_ANGULAR_SPEED := 180.0
const QUANTUM_JUMP_OFFSET := 100
const VELOCITY_RETENTION := 0.5
const THRUST_LENGTH := 48.0 # > 32.0
const THRUST_FACTOR := 0.3
const NO_THRUST_FACTOR := 1.0

const MAX_MISSILE_SLOTS := 5
const MISSILE_FIRE_INTERVAL := 1.5
const MISSILE_SLOT_RECOVERY_SECONDS := 7.5

var screen_size: Vector2
var angular_velocity := 0.0
var ghost := false
var birth := true
var is_eliminated := false
var qj_cooldown := true
var missile_slots := MAX_MISSILE_SLOTS
var missile_fire_cooldown := 0.0

func _ready() -> void:
	screen_size = get_viewport_rect().size
	global_position = spawn_position
	
	$Indicator.default_color = color
	thruster1.default_color = color
	thruster2.default_color = color
	laser.line_2d.default_color = color
	
	if birth:
		$GhostTimer.timeout.emit()
	else:
		ghost = true
		collision_layer = 4  # layer 3 = ghost
		collision_mask = 0
		$Sprite2D.modulate.a = 0.35

func _physics_process(delta: float) -> void:
	missile_fire_cooldown = max(missile_fire_cooldown - delta, 0.0)

	var direction = Global.star.global_position - global_position
	var distance = max(direction.length(), 30.0)
	if not ghost:
		var gravity_force = direction.normalized() * (Global.star.GRAVITY_STRENGTH / (distance * distance))
		velocity += gravity_force * delta

	if Input.is_action_pressed("rotate_left" + player_prefix):
		if Global.ENABLE_ANGULAR_INERTIA:
			angular_velocity -= ANGULAR_ACCELERATION * delta
		else:
			rotation_degrees -= ROTATION_SPEED * delta

	if Input.is_action_pressed("rotate_right" + player_prefix):
		if Global.ENABLE_ANGULAR_INERTIA:
			angular_velocity += ANGULAR_ACCELERATION * delta
		else:
			rotation_degrees += ROTATION_SPEED * delta

	if Input.is_action_just_pressed("bullet" + player_prefix) and not ghost:
		fire_bullet()

	if Input.is_action_just_pressed("missile" + player_prefix) and not ghost:
		try_fire_missile()

	if Input.is_action_pressed("laser" + player_prefix) and not ghost:
		if is_instance_valid(laser):
			laser.is_casting = true
		else:
			# Laser was destroyed, create a new one
			var laser_scene = load("res://scenes/laser.tscn")
			laser = laser_scene.instantiate()
			add_child(laser)
			# Set position and rotation to match FirePosition
			laser.global_position = $FirePosition.global_position
			laser.global_rotation = $FirePosition.global_rotation
			# Set color to match player
			laser.line_2d.default_color = color
			laser.is_casting = true
	else:
		if is_instance_valid(laser):
			laser.is_casting = false

	if Global.ENABLE_ANGULAR_INERTIA:
		rotation_degrees += angular_velocity * delta

	var forward = Vector2.UP.rotated(rotation)
	var is_thrusting = false
	if Input.is_action_pressed("forward_thrust" + player_prefix ):
		velocity += forward * THRUST * delta
		thruster_animation(true)
		is_thrusting = true
	if Input.is_action_pressed("reverse_thrust" + player_prefix ):
		velocity += -forward * THRUST * delta
		thruster_animation(true)
		is_thrusting = true
		
	if Input.is_action_just_pressed("quantum_jump" + player_prefix ):
		if qj_cooldown:
			quantum_jump()
			qj_cooldown=false
			$QJCooldown.start()

	if velocity.length() > MAX_SPEED:
		velocity = velocity.normalized() * MAX_SPEED
	
	if not is_thrusting:
		thruster_animation(false)
	move_and_slide()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:

	if global_position.x < 0:
		global_position.x = screen_size.x
	elif global_position.x > screen_size.x:
		global_position.x = 0

	if global_position.y < 0:
		global_position.y = screen_size.y
	elif global_position.y > screen_size.y:
		global_position.y = 0

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("star") or body.name == "Star":
		die("by entering the star")

func take_damage(amount: int) -> void:
	if is_eliminated:
		return

	health = max(health - amount, 0)
	print("Player " + str(int(player_prefix)) + " took " + str(amount) + " damage! Health: " + str(health))

	if health <= 0:
		die("after health reached zero")

func die(reason: String) -> void:
	if is_eliminated:
		return

	is_eliminated = true
	print("Player " + str(int(player_prefix)) + " died " + reason + "!")
	Spawner.respawn_player(self)
	
func quantum_jump() -> void:
	var random_position = Vector2(
	randf_range(0, screen_size.x),
	randf_range(0, screen_size.y)
	)

	if velocity.length() > 0:
		random_position += velocity.normalized() * QUANTUM_JUMP_OFFSET

	global_position = random_position

	velocity *= VELOCITY_RETENTION

func fire_bullet() -> void:
	Spawner.spawn_bullet(
		$FirePosition.global_position,
		Vector2.UP.rotated(rotation),
		self)

func try_fire_missile() -> void:
	if missile_slots <= 0 or missile_fire_cooldown > 0.0:
		return
	missile_slots -= 1
	missile_fire_cooldown = MISSILE_FIRE_INTERVAL
	Spawner.spawn_missile(
		$FirePosition.global_position,
		Vector2.UP.rotated(rotation),
		self)
	get_tree().create_timer(MISSILE_SLOT_RECOVERY_SECONDS).timeout.connect(_recover_missile_slot)

func _recover_missile_slot() -> void:
	missile_slots = min(missile_slots + 1, MAX_MISSILE_SLOTS)

func _on_ghost_timer_timeout() -> void:
	$Sprite2D.modulate.a = 1.0
	$Indicator.modulate.a = 1.0
	thruster1.modulate.a = 1.0
	thruster2.modulate.a = 1.0
	collision_layer = 1
	collision_mask = 59
	ghost = false

func _on_qj_cool_down_timeout() -> void:
	qj_cooldown=true

func thruster_animation(thrust : bool) -> void:
	if thrust:
		var tmp = thruster1.points
		if tmp[1].y < THRUST_LENGTH:
			tmp[1].y += THRUST_FACTOR
		thruster1.points = tmp
		tmp = thruster2.points
		if tmp[1].y < THRUST_LENGTH:
			tmp[1].y += THRUST_FACTOR
		thruster2.points = tmp
	else:
		var tmp = thruster1.points
		if tmp[1].y > 32.0:
			tmp[1].y -= NO_THRUST_FACTOR
		thruster1.points = tmp	
		tmp = thruster2.points
		if tmp[1].y > 32.0:
			tmp[1].y -= NO_THRUST_FACTOR
		thruster2.points = tmp
