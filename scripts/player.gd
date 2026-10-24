# SPDX-FileCopyrightText: 2026 Tirth Kavathiya <tirthkavathiya@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

extends RigidBody2D

@export var player_prefix : String
@export var color : Color
@export var hud : Control
@onready var laser = $Laser
@onready var thrusters = [$Thruster1, $Thruster2]

const MAX_HEALTH := 100
const WRAP_MARGIN := 48
const THRUST := 100.0
const MAX_SPEED := 800.0
const THRUST_LENGTH := 48.0 # > 32.0
const THRUST_FACTOR := 10.0
const NO_THRUST_FACTOR := 20.0
const ROTATION_SPEED := 100.0
const ANGULAR_DAMP := PI
const QUANTUM_JUMP_OFFSET := 100
const VELOCITY_RETENTION := 0.5
const MAX_MISSILE_SLOTS := 4
const MISSILE_FIRE_INTERVAL := 2.0
const MISSILE_SLOT_RECOVERY_SECONDS := 7.5

var screen_size: Vector2
var health := MAX_HEALTH
var missile_slots := MAX_MISSILE_SLOTS
var ghost := false
var birth := true
var is_eliminated := false
var qj_cooldown := true
var missile_fire_cooldown := 0.0
var touched := false
var qj_risk_value = 5
var target : RigidBody2D = null
enum Weapon { BULLET, MISSILE, LASER }
var equipped_weapon: Weapon = Weapon.BULLET

func _ready() -> void:
	max_contacts_reported = Global.PLAYERS
	screen_size = get_viewport_rect().size
	
	$Indicator.default_color = color
	thrusters[0].default_color = color
	thrusters[1].default_color = color
	laser.line_2d.default_color = color
	
	if birth:
		$GhostTimer.timeout.emit()
	else:
		SoundManager.ghost()
		ghost = true
		collision_layer = 4
		collision_mask = 0
		$Sprite2D.modulate.a = 0.35
		
	if not Global.ENABLE_ANGULAR_INERTIA:
		angular_damp = ANGULAR_DAMP
	

func _physics_process(delta: float) -> void:
	missile_fire_cooldown = max(missile_fire_cooldown - delta, 0.0)
	
	if Input.is_action_just_pressed("bullet" + player_prefix):
		equipped_weapon = Weapon.BULLET
	elif Input.is_action_just_pressed("missile" + player_prefix):
		equipped_weapon = Weapon.MISSILE
	elif Input.is_action_just_pressed("laser" + player_prefix):
		equipped_weapon = Weapon.LASER
		
	if Input.is_action_just_pressed("fire" + player_prefix) and not ghost:
		match equipped_weapon:
			Weapon.BULLET:
				fire_bullet()
				SoundManager.fire_bullet()
			Weapon.MISSILE:
				try_fire_missile()
			Weapon.LASER:
				pass
				
	if equipped_weapon == Weapon.LASER and Input.is_action_pressed("fire" + player_prefix) and not ghost and not laser.laser_overheated:
		laser.is_casting = true
	else:
		laser.is_casting = false
	if equipped_weapon == Weapon.LASER and Input.is_action_just_released("fire" + player_prefix) and laser.laser_overheated:
		laser.laser_overheated = false
		
	if $Target.is_colliding():
		# TODO : Add SFX
		var collider = $Target.get_collider()
		target = collider if collider is RigidBody2D else null
	else:
		target = null
	
func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	var direction = Global.star.global_position - state.transform.origin
	var distance = max(direction.length(), 30.0)
	if not ghost:
		var gravity_force = direction.normalized() * (Global.star.GRAVITY_STRENGTH / (distance * distance))
		state.apply_central_force(gravity_force)
	
	var forward = Vector2.UP.rotated(rotation)
	var thrust_direction := Vector2.ZERO
	if Input.is_action_pressed("forward_thrust" + player_prefix ):
		thrust_direction = forward
	elif Input.is_action_pressed("reverse_thrust" + player_prefix ):
		thrust_direction = -forward
	if thrust_direction != Vector2.ZERO:
		if state.linear_velocity.length() < MAX_SPEED:
			SoundManager.thrust(int(player_prefix), 0)
			thruster_animation(true, state.step)
		else:
			SoundManager.thrust(int(player_prefix),1)
			thruster_animation(false, state.step)
		state.apply_central_force(thrust_direction * THRUST)
	else:
		SoundManager.thrust(int(player_prefix),1)
		thruster_animation(false, state.step)
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
			SoundManager.qj()
			
	if state.transform.origin.x + WRAP_MARGIN < 0.0:
		state.transform.origin.x = screen_size.x + WRAP_MARGIN
	elif state.transform.origin.x - WRAP_MARGIN > screen_size.x:
		state.transform.origin.x = -WRAP_MARGIN

	if state.transform.origin.y + WRAP_MARGIN < 0.0:
		state.transform.origin.y = screen_size.y  + WRAP_MARGIN
	elif state.transform.origin.y - WRAP_MARGIN > screen_size.y:
		state.transform.origin.y = -WRAP_MARGIN
	
	var touching := state.get_contact_count() > 0
	if touching and not touched:
		SoundManager.collision()
	touched = touching

func quantum_jump(state : PhysicsDirectBodyState2D) -> void:
	var random_position = Global.randcc(float(qj_risk_value * 100))
	qj_risk_value -= 1 if qj_risk_value > 0 else 0
	if state.linear_velocity.length() > 0:
		random_position += state.linear_velocity.normalized() * QUANTUM_JUMP_OFFSET
	state.transform = Transform2D(randf_range(0, TAU), random_position)
	state.linear_velocity *= VELOCITY_RETENTION
	if Global.ENABLE_ANGULAR_INERTIA:
		state.angular_velocity *= VELOCITY_RETENTION

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
	SoundManager.fire_missile()
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
	# TODO : Add SFX
	qj_cooldown=true

func thruster_animation(thrust : bool, delta : float) -> void:
	for t in thrusters:
		if thrust:
			var tmp = t.points
			if tmp[1].y < THRUST_LENGTH:
				tmp[1].y += THRUST_FACTOR * delta
			t.points = tmp
		else:
			var tmp = t.points
			if tmp[1].y > 32.0:
				tmp[1].y -= NO_THRUST_FACTOR * delta
			t.points = tmp
