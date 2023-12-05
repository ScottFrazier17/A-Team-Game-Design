extends KinematicBody2D

enum {
    WANDER,
    CHASE,
    HANGING
}

const MOVE_SPEED = 500
const CHASE_SPEED = 700
const JUMP_FORCE = -1500
const DETECTION_RADIUS = 300

var GRAVITY = ProjectSettings.get_setting("physics/2d/default_gravity")
var velocity = Vector2.ZERO
var has_double_jump = false
var state = WANDER
var knockback = Vector2.ZERO
var direction = 1

onready var animation = get_node("AnimatedSprite")
onready var player = get_node("res://Player/Player.tscn")
onready var stats = $Stats

func _ready():
    velocity.x = MOVE_SPEED

func _physics_process(delta):

    match state:
        WANDER:
            #print("WANDERING")
            wander(delta)
        CHASE:
            print("CHASING")
            chase(delta)
        HANGING:
            print("HANGING")
            hanging()

    animation.play("Idle")
    velocity = move_and_slide(velocity, Vector2(0, -1))

func wander(delta):
    # Move back and forth until player is detected
    if is_on_wall():
        direction *= -1
    velocity.x = MOVE_SPEED * direction
    
    # Gravity
    velocity.y += GRAVITY * 4 * delta
    
    if is_player_nearby():
        state = CHASE

func chase(delta):
    
    # Move towards the player
    var player_direction = get_node("res://Player/Player.tscn").get_position_in_parent()
    velocity.x = CHASE_SPEED * player_direction
    # Gravity
    velocity.y += GRAVITY * 4 * delta

    if not is_player_nearby():
        state = WANDER

func hanging():
    # Flip upside down and stay still until player is nearby
    velocity = Vector2.ZERO
    scale.x *= -1  # Flip the sprite horizontally

    if is_player_nearby():
        state = CHASE

func is_player_nearby() -> bool:
    
    return player and position.distance_to(player.get_position_in_parent()) < DETECTION_RADIUS

func _on_Hurtbox_area_entered(_area):
#    knockback = area.knockback * 100
    stats.CURRENT_HEALTH -= 1

    print("OUCH!")
    if stats.CURRENT_HEALTH == 0:
        queue_free()
