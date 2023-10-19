extends KinematicBody2D

enum Direction{FACING_RIGHT = 1, FACING_LEFT = -1}
enum PlayerState{Idle, Walk, Jump, DoubleJump, In_Air, Dash, Climb, Grapple}

export var GRAVITY = 4000
export var MOVE_SPEED = 700
export var JUMP_FORCE = -1000
export var DASH_FORCE = 1750
const DASH_COOLDOWN = 0.25
export var dash_cooldown = DASH_COOLDOWN
export var wall_jump_multiplier = 1.5
const STAMINA = 3.0
export var stamina = STAMINA 
export var velocity = Vector2()
onready var animationPlayer = $AnimationPlayer
onready var animation = get_node("AnimatedSprite")
onready var player_right_ray_1 = $PlayerRightRay1
onready var player_right_ray_2 = $PlayerRightRay2
onready var player_left_ray_1 = $PlayerLeftRay1
onready var player_left_ray_2 = $PlayerLeftRay2
onready var player_grapple_rays = $GrappleRayCast
onready var grapple_string = $GrappleString
onready var state = PlayerState.Idle
onready var has_double_jump = true
onready var jumpfx = $Jump
onready var Dashfx = $Dash
onready var walk1fx = $Walk1
onready var walk2fx = $Walk2

var input_vector = Vector2()
  
func _physics_process(delta):
  
  input_vector.x = Input.get_axis("ui_left","ui_right")
  input_vector.y = Input.get_action_strength("ui_up")
  velocity.y += GRAVITY*delta
  
  match state:
    
    PlayerState.Idle:
        print("Idle")
        velocity.x = 0 
        state = update_state(state)
        
    PlayerState.Walk:
        input_vector.x = Input.get_axis("ui_left","ui_right")
        velocity.x = input_vector.x * MOVE_SPEED
        animation.play("Walk")
        orient_model()
        print("Walk")
        state = update_state(state)
        
    PlayerState.Jump:
        animation.play("Jump")
        jumpfx.play()
        velocity.y = JUMP_FORCE
        print("Jump")
        state = update_state(state)
        
    PlayerState.DoubleJump:
        animation.play("Jump")
        jumpfx.play()
        velocity.y = JUMP_FORCE
        print("Double Jump")
        state = update_state(state)
        
    PlayerState.In_Air:
        velocity.x = input_vector.x * MOVE_SPEED
        orient_model()
        print("In_Air")
        state = update_state(state)
        
    PlayerState.Dash:
        animation.play("Dash")
        if !Dashfx.is_playing():
          Dashfx.play()
        velocity.x = input_vector.x * DASH_FORCE 
        dash_cooldown -= delta
        print("Dash")
        state = update_state(state)
        
    PlayerState.Climb:
        velocity.y = -input_vector.y * 450
        stamina -= delta
        print("Climbing")
        state = update_state(state)
          
                         
    #PlayerState.Grapple:
    #    grapple_string.node_a = self.get_path()
    #    #velocity.y = 0
    #    print("Grappling")
    #    print(grapple_string.node_a)
    #    print(grapple_string.node_b)
    #    state = update_state(state)
    
                      
  velocity = move_and_slide(velocity,Vector2.UP)

func update_state(curr_state):
  input_vector.x = Input.get_axis("ui_left","ui_right")
  input_vector.y = Input.get_action_strength("ui_up")
  
  match curr_state:
    
    PlayerState.Idle:
      stamina = STAMINA
      animation.modulate = Color(1,1,1)
      has_double_jump = true
      
      if(move_pressed()):
        return PlayerState.Walk
      elif(jump_pressed()):
        return PlayerState.Jump
      elif(player_colliding_wall() and climb_pressed()):
        return PlayerState.Climb  
      else:
        return PlayerState.Idle
        
    PlayerState.Walk:
      if(move_not_pressed()):
        return PlayerState.Idle     
      elif(jump_pressed()):
        return PlayerState.Jump
      elif(dash_pressed()):
        return PlayerState.Dash
      elif(player_colliding_wall() and climb_pressed()):
        return PlayerState.Climb  
      else:
        return PlayerState.Walk
        
    PlayerState.Jump:
      if(!is_on_floor()):
        return PlayerState.In_Air
      else:
        return PlayerState.Jump  
        
    PlayerState.In_Air:
      if(!is_on_floor() and jump_pressed() and has_double_jump):
        return PlayerState.DoubleJump
      elif(is_on_floor()):
        return PlayerState.Idle
      elif(dash_pressed()):
        return PlayerState.Dash
      elif(player_colliding_wall() and climb_pressed() and stamina>0):
        return PlayerState.Climb
    #  elif(grapple_pressed() and near_hook()):
    #    return PlayerState.Grapple    
      else:
        return PlayerState.In_Air
        
    PlayerState.DoubleJump:
      has_double_jump = false
      return PlayerState.In_Air
      
    PlayerState.Dash:
      if(dash_cooldown <= 0):
        dash_cooldown = DASH_COOLDOWN
        return PlayerState.In_Air
      else:
        return PlayerState.Dash
        
    PlayerState.Climb:
      if(!(player_colliding_wall() and climb_pressed())):
        return PlayerState.In_Air
      elif(climb_pressed() and wall_jump_pressed()):
        velocity = Vector2(calc_diagonal_x(),calc_diagonal_y())
        return PlayerState.In_Air
      elif(stamina <= 0):
        animation.modulate = Color(1,0,0)
        return PlayerState.In_Air        
      else:
        return PlayerState.Climb 
              
    #PlayerState.Grapple:
    #  if(!grapple_pressed()):
    #    return PlayerState.In_Air
    #  else:
    #    return PlayerState.Grapple      
           
          
func move_pressed():
  if(Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right")):
    return true
  else:
    return false  
    
  
func move_not_pressed():
  if(!Input.is_action_pressed("ui_left") and !Input.is_action_pressed("ui_right")):
    return true
  else:
    return false 
    
                       
func jump_pressed():
  if Input.is_action_just_pressed("ui_up"):
    return true
  else:
    return false       
       

func orient_model():
  if(input_vector.x!=0):
    get_node("AnimatedSprite").flip_h = (input_vector.x < 0)    
    
      
func dash_pressed():
  if(Input.is_action_just_pressed("ui_select")):
    return true
  else:
    return false  
    
    
func player_colliding_wall():
  if(player_right_ray_1.is_colliding() and player_right_ray_2.is_colliding()):
    return true
  elif(player_left_ray_1.is_colliding() and player_left_ray_2.is_colliding()):
    return true
  else:
    return false 
    
    
func climb_pressed():
  if(Input.is_action_pressed("ui_ctrl")):
    return true
  else:
    return false 
    
    
func wall_jump_pressed():
  if(move_pressed() and jump_pressed()):
    return true
  else:
    return false 
    
    
func calc_diagonal_x():
  return input_vector.x*MOVE_SPEED*wall_jump_multiplier 
  
  
func calc_diagonal_y():
  return input_vector.y*JUMP_FORCE*wall_jump_multiplier   
  

func grapple_pressed():
  if(Input.is_action_pressed("ui_x")):
    return true
  else:
    return false    


func near_hook():
  for ray in player_grapple_rays.get_children():
    if(ray.is_colliding()):
      var target = ray.get_collider()
      var grapple_len = ray.get_collision_point().distance_to(self.global_position)
      grapple_string.length = grapple_len
      grapple_string.global_rotation_degrees = ray.global_rotation_degrees + 90
      grapple_string.node_b = target.get_path()
      return true
      
  
func handle_grapple():
  pass 


func respawn():
  get_tree().reload_current_scene()                               

