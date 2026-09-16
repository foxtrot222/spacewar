extends Area2D

const BULLET_SPEED := 800.0
const MAX_SPEED := 800.0
# Damage constants - missile does 50, bullet does 5
const BULLET_DAMAGE := 5

# No slots counter - missiles/bullets have unlimited fire with cooldown handled by player

var velocity: Vector2
var shooter: CharacterBody2D

func setup(start_position: Vector2, start_direction: Vector2, shooter_player: CharacterBody2D) -> void:
    global_position = start_position
    velocity = start_direction.normalized() * BULLET_SPEED
    rotation = start_direction.angle()
    shooter = shooter_player

func _physics_process(delta: float) -> void:
    # Maximum speed
    if velocity.length() > MAX_SPEED:
        velocity = velocity.normalized() * MAX_SPEED

    # Move bullet
    global_position += velocity * delta

    # Rotate toward movement direction
    rotation = velocity.angle()

func _on_body_entered(body: Node2D) -> void:
    if body is CharacterBody2D:
        if body == shooter:
            return

        var damage := BULLET_DAMAGE
        print("Bullet hit Player %s! Damage: %s" % [int(body.player_prefix), damage])
        body.take_damage(damage)
        queue_free()