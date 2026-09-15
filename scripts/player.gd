extends CharacterBody2D

@export var player_prefix : String
@export var texture : Texture2D
@export var spawn_position : Vector2

# Player health
const MAX_HEALTH := 100
var health := MAX_HEALTH

# Movement constants
const THRUST := 100.0
const MAX_SPEED := 800.0
const ROTATION_SPEED := 60.0
const ANGULAR_ACCELERATION := 120.0
const MAX_ANGULAR_SPEED := 180.0
const QUANTUM_JUMP_OFFSET := 100
const VELOCITY_RETENTION := 0.5

# Missile weapon settings
const MAX_MISSILE_SLOTS := 5
const MISSILE_FIRE_INTERVAL := 1.5
const MISSILE_SLOT_RECOVERY_SECONDS := 7.5

# Input state
var screen_size: Vector2
var angular_velocity := 0.0
var ghost := false
var is_eliminated := false
var qj_cooldown := true
var missile_slots := MAX_MISSILE_SLOTS
var missile_fire_cooldown := 0.0

func _ready() -> void:
\tscreen_size = get_viewport_rect().size
\t$Sprite2D.texture = texture
\tglobal_position = spawn_position
\tif birth:
\t\t$GhostTimer.timeout.emit()

func _physics_process(delta: float) -> void:
\tmissile_fire_cooldown = max(missile_fire_cooldown - delta, 0.0)

\t# Gravity
\tvar direction = Global.gravity_well.global_position - global_position
\tvar distance = max(direction.length(), 30.0)
\tif not ghost:
\t\tvar gravity_force = direction.normalized() * (Global.gravity_well.GRAVITY_STRENGTH / (distance * distance))
\t\tvelocity += gravity_force * delta

\t# Rotation
\tif Input.is_action_pressed("rotate_left" + player_prefix):
\t\tif Global.ENABLE_ANGULAR_INERTIA:
\t\t\tangular_velocity -= ANGULAR_ACCELERATION * delta
\t\telse:
\t\t\trotation_degrees -= ROTATION_SPEED * delta

\tif Input.is_action_pressed("rotate_right" + player_prefix):
\t\tif Global.ENABLE_ANGULAR_INERTIA:
\t\t\tangular_velocity += ANGULAR_ACCELERATION * delta
\t\telse:
\t\t\trotation_degrees += ROTATION_SPEED * delta

\tif Input.is_action_just_pressed("bullet" + player_prefix) and not ghost:
\t\tfire_bullet()

\tif Input.is_action_just_pressed("missile" + player_prefix) and not ghost:
\t\ttry_fire_missile()

\t# Apply rotation
\tif Global.ENABLE_ANGULAR_INERTIA:
\t\trotation_degrees += angular_velocity * delta

\t# Thrust
\tvar forward = Vector2.UP.rotated(rotation)

\tif Input.is_action_pressed("forward_thrust" + player_prefix ):
\t\tvelocity += forward * THRUST * delta
\tif Input.is_action_pressed("reverse_thrust" + player_prefix ):
\t\tvelocity += -forward * THRUST * delta

\tif Input.is_action_just_pressed("quantum_jump" + player_prefix ) and qj_cooldown:
\t\tquantum_jump()
\t\tqj_cooldown=false
\t\t$QJCooldown.start()

\t# Maximum speed
\tif velocity.length() > MAX_SPEED:
\t\tvelocity = velocity.normalized() * MAX_SPEED

\tmove_and_slide()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:

\tif global_position.x < 0:
\t\tglobal_position.x = screen_size.x
\telif global_position.x > screen_size.x:
\t\tglobal_position.x = 0

\tif global_position.y < 0:
\t\tglobal_position.y = screen_size.y
\telif global_position.y > screen_size.y:
\t\tglobal_position.y = 0

func _on_body_entered(body: Node2D) -> void:
\tif body.is_in_group("star") or body.name == "GravityWell":
\t\tdie("by entering the star")

func take_damage(amount: int) -> void:
\tif is_eliminated:
\t\treturn

\thealth = max(health - amount, 0)
\tprint("Player " + str(int(player_prefix)) + " took " + str(amount) + " damage! Health: " + str(health))

\tif health <= 0:
\t\tdie("after health reached zero")

func die(reason: String) -> void:
\tif is_eliminated:
\t\treturn

\tis_eliminated = true
\tprint("Player " + str(int(player_prefix)) + " died " + reason + "!")
\tGlobal.respawn_player(self)

func quantum_jump() -> void:
\tvar random_position = Vector2(
\t\trandf_range(0, screen_size.x),
\t\trandf_range(0, screen_size.y)
\t)

\tif velocity.length() > 0:
\t\trandom_position += velocity.normalized() * QUANTUM_JUMP_OFFSET

\tglobal_position = random_position

\t# Reduce momentum after teleport
\tvelocity *= VELOCITY_RETENTION

func fire_bullet() -> void:
\tGlobal.spawn_bullet(
\t\tglobal_position + Vector2.UP.rotated(rotation) * 30.0,
\t\tVector2.UP.rotated(rotation),
\t\tself
\t)

func try_fire_missile() -> void:
\tif missile_slots <= 0 or missile_fire_cooldown > 0.0:
\t\treturn

\tmissile_slots -= 1
\tmissile_fire_cooldown = MISSILE_FIRE_INTERVAL
\tGlobal.spawn_missile(
\t\tglobal_position + Vector2.UP.rotated(rotation) * 30.0,
\t\tVector2.UP.rotated(rotation),
\t\tself
\t)
\tget_tree().create_timer(MISSILE_SLOT_RECOVERY_SECONDS).timeout.connect(_recover_missile_slot)

func _recover_missile_slot() -> void:
\tmissile_slots = min(missile_slots + 1, MAX_MISSILE_SLOTS)

func _on_ghost_timer_timeout() -> void:
\t$Sprite2D.modulate.a = 1.0
\tcollision_layer = 1
\tcollision_mask = 3
\tghost = false

func _on_qj_cool_down_timeout() -> void:
\tqj_cooldown=true

var birth := true