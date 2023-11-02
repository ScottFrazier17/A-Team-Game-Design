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
export var velocity = Vector2()
#onready var animationPlayer = $AnimationPlayer
onready var animation = get_node("AnimatedSprite")

onready var player_right_ray_1 = $PlayerRightRay1
onready var player_right_ray_2 = $PlayerRightRay2
onready var player_left_ray_1 = $PlayerLeftRay1
onready var player_left_ray_2 = $PlayerLeftRay2
#onready var player_grapple_rays = $GrappleRayCast

#onready var grapple_string = $GrappleString
onready var state = PlayerState.Idle
onready var has_double_jump = true

onready var jumpfx = $Jump
onready var Dashfx = $Dash
onready var walk1fx = $Walk1
onready var walk2fx = $Walk2

const STAMINA = 100
const STAMINA_DRAIN = 20
const STAMINA_REGEN = 20
const STAMINA_REGEN_HOLDUP = 5 #variable that determines how long it takes before stamina starts recovering
const STAMINA_REGEN_HOLDUP_COUNTDOWN_FACTOR = 5
const DASH_STAMINA_CONSUMPTION_MULTIPLIER = 3
const STAMINA_BLINK_COUNTDOWN = 0.4
onready var stamina = STAMINA 
onready var StaminaPie = $StaminaPie
onready var StaminaDrain = STAMINA_DRAIN
onready var StaminaRegen = STAMINA_REGEN
onready var StaminaRegenLag = STAMINA_REGEN_HOLDUP

var hookDetector = Area2D.new()
var hookDetectorCollision = CollisionShape2D.new()
var hookDetectorShape = CircleShape2D.new()
var hookDetectorRadius = 1000
var hookObjects = []
var bodiesToRemove = []
onready var hook_selector = $HookSelector
onready var nearestHook = null
var player_to_hook_vector = Vector2.ZERO
var tangential_vel: Vector2
var was_in_grapple = false
const TAN_COUNT = 0.4
var tangential_countdown = TAN_COUNT
var swingingRight = false
var swingingLeft = false
var hookLocked = null
var factor = 3
var swing_opp = true
var HookObject = null
var HookArea = null
var bodyPos:Vector2
var hookPos:Vector2
var grapple_len: float 

var input_vector = Vector2()
func _ready():
  hookDetectorShape.set_radius(hookDetectorRadius)
  hookDetectorCollision.set_shape(hookDetectorShape)
  hookDetector.add_child(hookDetectorCollision)
  #hookDetector.monitoring = false
  add_child(hookDetector)
   
func _physics_process(delta):
  print(velocity)
  input_vector.x = Input.get_axis("ui_left","ui_right")
  input_vector.y = Input.get_action_strength("ui_up")
  
  update_stamina_objects(delta) 
   
  hookObjects = hookDetector.get_overlapping_bodies()
  var i = hookObjects.size()-1
  for body in range(hookObjects.size()):
    if (!hookObjects[i].name.begins_with("Hook")):
      hookObjects.remove(i)
    i = i - 1
  #var nearestHook = null  
  if(Input.is_action_pressed("ui_c")):
    nearestHook = player_selects_hook()
  
  nearestHook = find_nearest_hook_in_direction()
  #print(nearestHook)
  match state:
    
    PlayerState.Idle:
        velocity.y += GRAVITY*delta
        if(StaminaRegenLag >0 and StaminaRegenLag<=30):
         StaminaRegenLag -= delta*STAMINA_REGEN_HOLDUP_COUNTDOWN_FACTOR
        if(StaminaRegenLag <= 0 and stamina <=100):
        #if(stamina <=100):
         stamina += delta*StaminaRegen
        #print(stamina)
        update_stamina_objects(delta)
         #StaminaPie.value = stamina
        #print("Idle")
        velocity.x = 0 
        state = update_state(state)
        
    PlayerState.Walk:
        velocity.y += GRAVITY*delta
        if(StaminaRegenLag >0 and StaminaRegenLag<=30):
         StaminaRegenLag -= delta*STAMINA_REGEN_HOLDUP_COUNTDOWN_FACTOR
        if(StaminaRegenLag <= 0 and stamina <=100):
         stamina += delta*StaminaRegen
        update_stamina_objects(delta)
        #StaminaPie.value = stamina
        input_vector.x = Input.get_axis("ui_left","ui_right")
        velocity.x = input_vector.x * MOVE_SPEED
        animation.play("Walk")
        orient_model()
        #print("Walk")
        state = update_state(state)
        
    PlayerState.Jump:
        velocity.y += GRAVITY*delta
        update_stamina_objects(delta)
        animation.play("Jump")
        jumpfx.play()
        velocity.y = JUMP_FORCE
        #print("Jump")
        state = update_state(state)
        
    PlayerState.DoubleJump:
        velocity.y += GRAVITY*delta
        update_stamina_objects(delta)
        animation.play("Jump")
        jumpfx.play()
        velocity.y = JUMP_FORCE
        #print("Double Jump")
        state = update_state(state)
        
    PlayerState.In_Air:
        if(StaminaRegenLag >0 and StaminaRegenLag<=30):
         StaminaRegenLag -= delta*STAMINA_REGEN_HOLDUP_COUNTDOWN_FACTOR
        if(StaminaRegenLag <= 0):
         stamina += delta*StaminaRegen
        update_stamina_objects(delta)
        #StaminaPie.value = stamina
        if(was_in_grapple and tangential_countdown > 0):
          velocity = tangential_vel
          tangential_countdown = tangential_countdown - delta
        else:
          velocity.y += GRAVITY*delta  
          velocity.x = input_vector.x * MOVE_SPEED
        orient_model()
        #print("In_Air")
        state = update_state(state)
        
    PlayerState.Dash:
        velocity.y += GRAVITY*delta
        stamina -= delta*StaminaDrain*DASH_STAMINA_CONSUMPTION_MULTIPLIER
        StaminaRegenLag = STAMINA_REGEN_HOLDUP
        update_stamina_objects(delta)
        #StaminaPie.value = stamina
        animation.play("Dash")
        if !Dashfx.is_playing():
          Dashfx.play()
        velocity.x = input_vector.x * DASH_FORCE 
        dash_cooldown -= delta
        #print("Dash")
        state = update_state(state)
        
    PlayerState.Climb:
        velocity.y += GRAVITY*delta
        animation.play("Walk")
        velocity.y = -input_vector.y * 450
        stamina -= delta*StaminaDrain
        StaminaRegenLag = STAMINA_REGEN_HOLDUP
        update_stamina_objects(delta)
        #StaminaPie.value = stamina
        #print("Climbing")
        state = update_state(state)
    PlayerState.Grapple:
      if(hookLocked):
        #velocity.y += GRAVITY*delta
        player_to_hook_vector = (hookLocked.global_position)-(global_position)
        grapple_len = global_position.distance_to(hookLocked.global_position)
        World_Info.BodyPosition = global_position
        World_Info.HookPosition = hookLocked.global_position
        var x = Input.get_axis("ui_left","ui_right")*MOVE_SPEED
        
        var angle = get_angle(hookLocked) 
        var normal_to_grapple = Vector2(-player_to_hook_vector.y, player_to_hook_vector.x)
        
        if(Input.get_axis("ui_left","ui_right")==0):
          if(swingingLeft and !swingingRight):
            velocity = -2.5*normal_to_grapple + 0.3*player_to_hook_vector
          if(swingingRight and !swingingLeft):
            velocity = 2.5*normal_to_grapple + 0.3*player_to_hook_vector  
        if(Input.get_axis("ui_left","ui_right") > 0):
          swingingLeft = false
          swingingRight = true
          velocity = 3*normal_to_grapple + 0.05*player_to_hook_vector
        if(Input.get_axis("ui_left","ui_right")< 0):
          swingingRight = false
          swingingLeft = true
          velocity = -3*normal_to_grapple + 0.05*player_to_hook_vector   
      print("Grapple")  
      #print(player_to_hook_vector)
      state = update_state(state)
                     
  velocity = move_and_slide(velocity,Vector2.UP)

func update_state(curr_state):
  input_vector.x = Input.get_axis("ui_left","ui_right")
  input_vector.y = Input.get_action_strength("ui_up")
  
  
  match curr_state:
    
    PlayerState.Idle:
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
        animation.stop()
        return PlayerState.Idle     
      elif(jump_pressed()):
        return PlayerState.Jump
      elif(dash_pressed() and stamina > 0):
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
      elif(dash_pressed() and stamina >0):
        return PlayerState.Dash
      elif(player_colliding_wall() and climb_pressed() and stamina>0):
        return PlayerState.Climb
      elif(hookObjects.size() > 0 and Input.is_action_pressed("ui_x")):
        World_Info.init_angle = get_angle(World_Info.selectedHook)
        hookLocked = World_Info.selectedHook
        return PlayerState.Grapple
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
        animation.stop()
        return PlayerState.In_Air
      elif(climb_pressed() and wall_jump_pressed()):
        animation.stop()
        velocity = Vector2(calc_diagonal_x(),calc_diagonal_y())
        return PlayerState.In_Air
      elif(stamina <= 0):
        animation.stop()
        #animation.modulate = Color(1,0,0)
        return PlayerState.In_Air        
      else:
        return PlayerState.Climb 
    
    PlayerState.Grapple:
      World_Info.grapple_draw = true
      if(!(Input.is_action_pressed("ui_x") and hookObjects.size() > 0)):
        World_Info.grapple_draw = false
        hookLocked = null
        tangential_vel = velocity
        was_in_grapple = true
        swingingLeft = false
        swingingRight = false
        tangential_countdown = TAN_COUNT
        return PlayerState.In_Air
      else:
        return PlayerState.Grapple                  
           
          
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
    #StaminaPie.rect_rotation = -220.0
    return true
  elif(player_left_ray_1.is_colliding() and player_left_ray_2.is_colliding()):
    return true
  else:
    return false 
    
    
func climb_pressed():
  if(Input.is_action_pressed("ui_shift")):
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


func respawn():
  if get_tree().reload_current_scene() != OK:
    print("respawn failed")                               

func update_stamina_objects(_delta):
  StaminaPie.value = stamina
  
  if(player_right_ray_1.is_colliding() or player_right_ray_2.is_colliding()):
      StaminaPie.rect_rotation = -220
  else:
    StaminaPie.rect_rotation = 0
  
       
  if StaminaPie.value == STAMINA:
    StaminaPie.visible = false
  else:
    StaminaPie.visible = true
    
    
  if(stamina > 0.5*STAMINA):
    StaminaPie.tint_progress = Color(0,1,0,1)
    
  if(stamina <= 0.5*STAMINA and stamina > 0.3*STAMINA):
    StaminaPie.tint_progress = Color(1,1,0,1)
    animation.modulate = Color(1,1,0)
  
  if(stamina <=0.3*STAMINA):
    StaminaPie.tint_progress = Color(1,0,0,1)
    animation.modulate = Color(1,0,0)
    
func player_selects_hook():
  #hook_selector.rotation = 0
  if(Input.is_action_just_pressed("ui_up")):
    while hook_selector.rotation < 3.14:
      hook_selector.rotate(0.785)
    World_Info.selectedHook = get_hook_collider()
    #if(Input.is_action_just_pressed("ui_right")):
    #  while !hook_selector_get_collider():
          
  if(Input.is_action_just_pressed("ui_down")):
    while hook_selector.rotation < 3.1:
      hook_selector.rotate(0.785)
  if(Input.is_action_just_pressed("ui_up")):
    while hook_selector.rotation < 3.14:
      hook_selector.rotate(0.785)
  if(Input.is_action_just_pressed("ui_up")):
    while hook_selector.rotation < 3.14:
      hook_selector.rotate(0.785)            
    
  return null
  
func find_nearest_hook_in_direction(): 
  var nearestHook = null
  var distance = hookDetectorRadius
  for hook in hookObjects:
    var curr_distance = global_position.distance_to(hook.global_position)
    #print(curr_distance)
    if curr_distance <= distance:
      #if()
      nearestHook = hook
      distance = curr_distance
  World_Info.selectedHook = nearestHook
  return nearestHook               

func get_hook_collider():
  if hook_selector.get_collider().name.begins_with("Hook"):
    return hook_selector.get_collider()
  else:
    return null  
func hook_selector_get_collider():
  var collider = null
  if hook_selector.get_collider() != World_Info.selectedHook:
    return hook_selector.get_collider()
    
func get_angle(nearestHook):
  var player_to_hook_vector = (nearestHook.global_position)-(global_position)
  if(global_position.x <= nearestHook.global_position.x):
    return acos(player_to_hook_vector.dot(Vector2(0,-1))/(player_to_hook_vector.length()))
  else:
    return acos(player_to_hook_vector.dot(Vector2(0,-1))/(player_to_hook_vector.length()))    
