extends KinematicBody2D
var dir: Vector2

var velocity = Vector2.ZERO
var MOVE_SPEED
var GRAVITY = 500
var angle = 0
var playerToLeftOfOrangeSlime
var starting_pos = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
  $SpawnOut.set_wait_time(4)
  starting_pos = global_position
  #MOVE_SPEED = pow(World_Info.spike_range_multiplier*GRAVITY,0.5)
  velocity = get_vel()
  velocity = velocity.clamped(3000)
  
  #velocity = (World_Info.slime_to_player+Vector2(0,-0.7*abs(World_Info.slime_to_player.x)))*MOVE_SPEED#Vector2(-1,-1)*MOVE_SPEED
  #dir = World_Info.poison_spike_dir
  
  
  
  #angle = get_dir()
  #print(angle)
  #if(playerToLeftOfOrangeSlime):
  #  var vel_dir = Vector2(-cos(angle),-sin(angle))
  #  velocity = MOVE_SPEED*vel_dir
  #else:
  #  var vel_dir = Vector2(cos(angle),-sin(angle))  
  #  velocity = MOVE_SPEED*vel_dir#(World_Info.poison_spike_dir.normalized())
    
  #print(World_Info.spike_range_multiplier)
  #print(World_Info.slime_to_player.x) 
  #print(velocity) 

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
  print(velocity)
  
  if $SpawnOut.is_stopped():
    $SpawnOut.start()
  #print(velocity)
  velocity.y += GRAVITY*delta
  var collision = move_and_collide(velocity*delta)
  if(collision):
    velocity = velocity.bounce(collision.normal)*0.3
  
      
func get_dir():
  var range_x = abs((World_Info.slime_to_player).x)
  if(World_Info.slime_to_player.x <= 0):
    playerToLeftOfOrangeSlime = true
  else:
    playerToLeftOfOrangeSlime = false  
 
  var v = MOVE_SPEED
  var g = GRAVITY
  var x = World_Info.slime_to_player.x
  var y = World_Info.slime_to_player.y
  
  
  var angle = g*x*x + 2*v*v*y
  angle = pow(angle,0.5)
  angle = angle + v*v 
  angle = angle/(g*x)
  angle = atan(angle) 
  return angle 
  
  
func get_vel():
  var spike_to_player = World_Info.player_pos - starting_pos
  var spike_height = min(spike_to_player.y-10, -10) 
  var vel = Vector2.ZERO
  if spike_to_player.y > spike_height:
    var time_spent_going_up = sqrt(-2*spike_height/float(GRAVITY))
    var time_spent_going_down = sqrt(2*(spike_to_player.y - spike_height)/float(GRAVITY))
    vel.y = -sqrt(-2*GRAVITY*spike_height)
    vel.x = spike_to_player.x/float(time_spent_going_up+time_spent_going_down)

  return vel
func _on_Area2D_body_entered(body):
  if(body.name.begins_with("Player")):
   if body.has_method("_on_Hurtbox_area_entered"):
      body._on_Hurtbox_area_entered(self)
      queue_free()
  


func _on_Area2D_body_exited(body):
  if(body.name.begins_with("Player")):
    if body.has_method("_on_Hurtbox_area_exited"):
      body._on_Hurtbox_area_exited(self)


func _on_SpawnOut_timeout():
  queue_free()
