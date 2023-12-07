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
#onready var Player = get_node("res://Player/Player.tscn")

var poison_spike_scene = preload("res://Enemies/PoisonSpike.tscn")
onready var shooting_range_area2D = $ShootingRange
onready var shooting_range_width = get_node("ShootingRange/CollisionShape2D").get_shape().get_extents().x
onready var player_in_sight = false
onready var HurtFx = $Hurt
onready var stats = $Stats
var shootingRange

func _ready():
    World_Info.spike_range_multiplier = shooting_range_width
    
    #print(stats.MAX_HEALTH)
    #print(stats.CURRENT_HEALTH)
    #velocity.x = MOVE_SPEED
    $Timer.set_wait_time(0.5)
    $ShootTimer.set_wait_time(1)
    

func _physics_process(delta):
    #print(Player)
    
    player_in_sight = determineShootingDir()
    
    #World_Info.poison_spike_dir = dir
    #print("spawning")
    
    #print(player_in_sight)
    if($ShootTimer.is_stopped() and player_in_sight):
      $ShootTimer.start()
      var poison_spike_instance = poison_spike_scene.instance()
      get_parent().add_child(poison_spike_instance)
      poison_spike_instance.global_position = global_position 
    
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
#    if !HurtFx.playing:
#            HurtFx.play()
    if($Timer.is_stopped()):
        $Timer.start()
    #stats.CURRENT_HEALTH -= 1

    #print("OUCH!")
    #if stats.CURRENT_HEALTH == 0:
    #    queue_free()


func _on_Timer_timeout():
  queue_free()




func _on_ShootTimer_timeout():
  $ShootTimer.stop()
  $ShootTimer.set_wait_time(1)
  pass # Replace with function body.
  
func determineShootingDir():
  var shootableBodies = shooting_range_area2D.get_overlapping_bodies()
  #print(shootableBodies)
  for body in shootableBodies:
    if body.name.begins_with("Player"):
      #print("SHOOT")
      World_Info.poison_spike_dir = World_Info.player_pos - global_position
      World_Info.slime_to_player = World_Info.player_pos - global_position
      return true
  return false    
    
  
