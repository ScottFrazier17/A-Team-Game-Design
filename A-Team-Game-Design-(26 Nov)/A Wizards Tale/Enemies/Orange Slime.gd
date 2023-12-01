extends KinematicBody2D

enum{
    IDLE,
    WANDER,
    CHASE,
    HANGING,
    ATTACK
   }

const MOVE_SPEED = 500
const JUMP_FORCE = -1500
var GRAVITY = ProjectSettings.get_setting("physics/2d/default_gravity")
var velocity = Vector2.ZERO
var has_double_jump = false
var state = IDLE
var knockback = Vector2.ZERO
var direction = 1
var dir = Vector2.ZERO
onready var animation = get_node("AnimatedSprite")
onready var stats = $Stats

func _ready():
    #print(stats.MAX_HEALTH)
    #print(stats.CURRENT_HEALTH)
    velocity.x = MOVE_SPEED
    $Timer.set_wait_time(0.5)
    

func _physics_process(delta):
    #dir = get_global_mouse_position()
    #dir = dir - global_position
    #dir = Vector2(-1,1)
    
    #World_Info.poison_spike_dir = dir
    # Gravity
    velocity.y += GRAVITY * 4 * delta
    if is_on_wall():
        direction *= -1
        velocity.x = MOVE_SPEED * direction 
    
    animation.play("Idle")
#    knockback = knockback.move_toward(Vector2.ZERO, 200 * delta)
#    knockback = move_and_slide(knockback)

    velocity = move_and_slide(velocity, Vector2(0, -1))
    
    match state:
        IDLE:
            pass
        WANDER:
            pass
        CHASE:
            pass
        HANGING:
            pass
        ATTACK:
            pass    

func _on_Hurtbox_area_entered(_area):
    animation.modulate = Color(1,0,0)
    if($Timer.is_stopped()):
        $Timer.start()
    stats.CURRENT_HEALTH -= 1

    print("OUCH!")
    if stats.CURRENT_HEALTH == 0:
        queue_free()


func _on_Timer_timeout():
  queue_free()


