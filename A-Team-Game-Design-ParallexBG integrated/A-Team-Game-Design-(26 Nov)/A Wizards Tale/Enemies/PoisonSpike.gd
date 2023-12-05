extends KinematicBody2D
var dir: Vector2

var velocity = Vector2.ZERO
const MOVE_SPEED = 1
const GRAVITY = 1300
var angle = 0
var playerToLeftOfOrangeSlime

# Called when the node enters the scene tree for the first time.
func _ready():
  $SpawnOut.set_wait_time(4)
  
  velocity = (World_Info.slime_to_player+Vector2(0,-0.7*abs(World_Info.slime_to_player.x)))*MOVE_SPEED#Vector2(-1,-1)*MOVE_SPEED
  #dir = World_Info.poison_spike_dir
  angle = get_dir()
  #if(playerToLeftOfOrangeSlime):
  #  var vel_dir = Vector2(-cos(angle),sin(angle))
  #  velocity = MOVE_SPEED*vel_dir
  #else:
  #  var vel_dir = Vector2(cos(angle),sin(angle))  
  #  velocity = MOVE_SPEED*vel_dir#(World_Info.poison_spike_dir.normalized())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
  if $SpawnOut.is_stopped():
    $SpawnOut.start()
  #print(velocity)
  velocity.y += GRAVITY*delta
  var collision = move_and_collide(velocity*delta)
  if(collision):
    velocity = velocity.bounce(collision.normal)*0.5
  
      
func get_dir():
  var range_x = abs((World_Info.slime_to_player).x)
  if(World_Info.slime_to_player.x <= 0):
    playerToLeftOfOrangeSlime = true
  else:
    playerToLeftOfOrangeSlime = false  
  var u = MOVE_SPEED
  var g = GRAVITY
  
  var rangeTimeGravity = asin((range_x * g)/(u*u))
  print(rangeTimeGravity)
  
  


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
