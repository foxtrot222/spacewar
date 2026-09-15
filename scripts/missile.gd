extends Area2D

const MISSILE_SPEED := 500.0
const MISSILE_LIFETIME := 5.0
const MISSILE_DAMAGE := 50

var velocity: Vector2
var shooter: CharacterBody2D
var life_timer: Timer

func _ready() -> void:
\tlife_timer = $LifeTimer
\tlife_timer.timeout.connect(queue_free)

func setup(
\tstart_position: Vector2,
\tstart_direction: Vector2,
\tshooter_player: CharacterBody2D
) -> void:
\tglobal_position = start_position
\tvelocity = start_direction.normalized() * MISSILE_SPEED
\trotation = start_direction.angle()
\tshooter = shooter_player
\tlife_timer.start()

func _physics_process(delta: float) -> void:
\t# Gravity
\tvar direction_to_star = Global.gravity_well.global_position - global_position
\tvar distance = max(direction_to_star.length(), 30.0)
\tvar gravity_force = direction_to_star.normalized() * (Global.gravity_well.GRAVITY_STRENGTH / (distance * distance))
\tvelocity += gravity_force * delta

\t# Move missile
\tglobal_position += velocity * delta

\t# Rotate toward movement direction
\trotation = velocity.angle()

\tif global_position.distance_to(Global.gravity_well.global_position) > 1500:
\t\tqueue_free()

func _on_body_entered(body: Node2D) -> void:
\tif body is CharacterBody2D:
\t\tif body == shooter:
\t\t\treturn

\t\t# Deal missile damage
\t\tbody.take_damage(MISSILE_DAMAGE)
\t\tprint("Missile hit Player " + str(int(body.player_prefix)) + "! Damage: " + str(MISSILE_DAMAGE))
\t\tqueue_free()

func _on_life_timer_timeout() -> void:
\tqueue_free()