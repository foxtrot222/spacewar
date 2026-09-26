extends RigidBody2D

@export var player_prefix : String
@export var color : Color
@export var spawn_position : Vector2

@onready var laser = $Laser
@onready var thruster1 = $Thruster1
@onready var thruster2 = $Thruster2

const MAX_HEALTH := 100
var health := MAX_HEALTH

const WRAP_MARGIN := 48

const THRUST := 100.0
const MAX_SPEED := 800.0
const THRUST_LENGTH := 48.0 # > 32.0
const THRUST_FACTOR := 0.3
const NO_THRUST_FACTOR := 1.0

const ROTATION_SPEED := 100.0
const ANGULAR_DAMP := 2.5

const QUANTUM_JUMP_OFFSET := 100
const VELOCITY_RETENTION := 0.5

const MAX_MISSILE_SLOTS := 5
const MISSILE_FIRE_INTERVAL := 1.5
const MISSILE_SLOT_RECOVERY_SECONDS := 7.5

const MAX_LASER_TIME := 100.0
const LASER_POINTS := 50.0

var screen_size: Vector2
var ghost := false
var birth := true
var is_eliminated := false
var qj_cooldown := true
var missile_slots := MAX_MISSILE_SLOTS
var missile_fire_cooldown := 0.0
var laser_cooldown := 100.0

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
		collision_layer = 4
		collision_mask = 0
		$Sprite2D.modulate.a = 0.35
		
	if not Global.ENABLE_ANGULAR_INERTIA:
		angular_damp = ANGULAR_DAMP

func _physics_process(delta: float) -> void:
	missile_fire_cooldown = max(missile_fire_cooldown - delta, 0.0)
	if Input.is_action_just_pressed("bullet" + player_prefix) and not ghost:
		fire_bullet()
	if Input.is_action_just_pressed("missile" + player_prefix) and not ghost:
		try_fire_missile()
	if Input.is_action_pressed("laser" + player_prefix) and not ghost and laser_cooldown > 0.0:
		laser_cooldown -= LASER_POINTS * delta
		laser.is_casting = true
	else:
		if laser_cooldown < MAX_LASER_TIME:
			laser_cooldown += LASER_POINTS * delta
		laser.is_casting = false

	
func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	var direction = Global.star.global_position - state.transform.origin
	var distance = max(direction.length(), 30.0)
	if not ghost:
		var gravity_force = direction.normalized() * (Global.star.GRAVITY_STRENGTH / (distance * distance))
		state.apply_central_force(gravity_force)
	
	var is_thrusting = false
	var forward = Vector2.UP.rotated(rotation)
	if Input.is_action_pressed("forward_thrust" + player_prefix ):
		state.apply_central_force(forward * THRUST)
		thruster_animation(true)
		is_thrusting = true
	if Input.is_action_pressed("reverse_thrust" + player_prefix ):
		state.apply_central_force(-forward * THRUST)
		thruster_animation(true)
		is_thrusting = true
	if not is_thrusting:
		thruster_animation(false)
	if state.linear_velocity.length() > MAX_SPEED:
		state.linear_velocity = state.linear_velocity.normalized() * MAX_SPEED
	
	if Input.is_action_pressed("rotate_left" + player_prefix):
		state.apply_torque_impulse(-ROTATION_SPEED)
	if Input.is_action_pressed("rotate_right" + player_prefix):
		state.apply_torque_impulse(ROTATION_SPEED)

	if Input.is_action_just_pressed("quantum_jump" + player_prefix ) and not ghost:
		if qj_cooldown:
			quantum_jump(state)
			qj_cooldown=false
			$QJCooldown.start()
			
	if state.transform.origin.x + WRAP_MARGIN < 0:
		state.transform.origin.x = screen_size.x + WRAP_MARGIN
	elif state.transform.origin.x - WRAP_MARGIN > screen_size.x:
		state.transform.origin.x = -WRAP_MARGIN

	if state.transform.origin.y + WRAP_MARGIN < 0:
		state.transform.origin.y = screen_size.y  + WRAP_MARGIN
	elif state.transform.origin.y - WRAP_MARGIN > screen_size.y:
		state.transform.origin.y = -WRAP_MARGIN

func quantum_jump(state : PhysicsDirectBodyState2D) -> void:
	var random_position = Vector2(
	randf_range(0, screen_size.x),
	randf_range(0, screen_size.y)
	)
	if state.linear_velocity.length() > 0:
		random_position += state.linear_velocity.normalized() * QUANTUM_JUMP_OFFSET
	state.transform.origin = random_position
	state.linear_velocity *= VELOCITY_RETENTION

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
	
func fire_bullet() -> void:
	Spawner.spawn_bullet(
		$FirePosition.global_position,
		Vector2.UP.rotated(rotation),
		color)

func try_fire_missile() -> void:
	if missile_slots <= 0 or missile_fire_cooldown > 0.0:
		return
	missile_slots -= 1
	missile_fire_cooldown = MISSILE_FIRE_INTERVAL
	Spawner.spawn_missile(
		$FirePosition.global_position,
		Vector2.UP.rotated(rotation),
		color)
	get_tree().create_timer(MISSILE_SLOT_RECOVERY_SECONDS).timeout.connect(_recover_missile_slot)

func _recover_missile_slot() -> void:
	missile_slots = min(missile_slots + 1, MAX_MISSILE_SLOTS)

func _on_ghost_timer_timeout() -> void:
	$Sprite2D.modulate.a = 1.0
	$Indicator.modulate.a = 1.0
	collision_layer = 1
	collision_mask = 3
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
