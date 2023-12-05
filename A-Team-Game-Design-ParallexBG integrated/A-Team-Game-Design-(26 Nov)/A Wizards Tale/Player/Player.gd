extends KinematicBody2D

#                                    CONTROLS                                     #

#    DICTIONARY FOR KEYS:
#    {
#       SIDE KEY  =  "ui_left" or "ui_right"
#       UP KEY     =  "ui_up"
#       SPACE KEY  =  "ui_select"
#       SHIFT KEY  =  "ui_shift"
#       X KEY      =  "ui_x" 
#    }
#
#
#    ACTION    ---> KEYS [+OPTIONAL KEY] {CONDITIONS}  
#
#    Walk                    --->  SIDE KEY                          {while ground}
#    Dash                    --->  SPACE KEY          [+SIDE KEY]    {while on ground OR in air}
#    Jump                    --->  UP KEY                            {while ground}
#    Double Jump             --->  UP KEY                            {while in air AND have only jumped once to get in air}
#    Wall Climb              --->  SHIFT KEY          [+UP KEY]      {while in contact with wall}
#    Wall Diagonal Jump      --->  UP KEY + SIDE KEY                 {while wall climbing}
#    Grapple                 --->  X KEY              [+SIDE KEY]    {while in air AND near grapple hook}

#                                END-OF-CONTROLS                                 #



#enumeration used to denote the states the player can be in
enum PlayerState{Idle, Walk, Jump, DoubleJump, In_Air, Dash, Climb, Grapple}
enum PlayerDirection{Left,Right}
#Physics constants/vars, used in all states
const GRAVITY = 3000#4000
const MOVE_SPEED = 700

#Constants/vars used in Jump and Dash states
const JUMP_FORCE = -1000
const DASH_FORCE = 1750
const DASH_COOLDOWN = 0.25
var dash_cooldown = DASH_COOLDOWN 
var wall_jump_multiplier = 1.5  #multiplier used when diagonal wall jumping, to increase jump force


onready var animation = get_node("AnimatedSprite")

#These raycasts are used for detecting walls to the left and right
onready var player_right_ray_1 = $PlayerRightRay1
onready var player_right_ray_2 = $PlayerRightRay2
onready var player_left_ray_1 = $PlayerLeftRay1
onready var player_left_ray_2 = $PlayerLeftRay2

#The initial state of the player is IDLE
onready var state = PlayerState.Idle
#The player starts off with double jump possible
onready var has_double_jump = true

#Sound effects for Walk, Jump, Dash
onready var jumpfx = $Jump
onready var Dashfx = $Dash
onready var walk1fx = $Walk1
onready var walk2fx = $Walk2
onready var stats = $Stats

#Constants that deal with Stamina of the player
const STAMINA = 100                                #max base Stamina of player
const STAMINA_DRAIN = 20                           #rate at which Stamina depletes when doing Stamina consuming action (this is the rate depletion for jump action)
const STAMINA_REGEN = 20                           #rate at which Stamina regenerates when in IDLE, WALK state
const STAMINA_REGEN_HOLDUP = 5                     #constant that determines how long it takes before stamina starts recovering
const STAMINA_REGEN_HOLDUP_COUNTDOWN_FACTOR = 5    #multiplies with delta to decrease the amount of time until stamina can start regenerating
const DASH_STAMINA_CONSUMPTION_MULTIPLIER = 3      #dash consumes more Stamina than jumping by this factor            
onready var StaminaPie = $StaminaPie               #TextureProgress object that displays Player Stamina on screen
onready var stamina = STAMINA                      #Current Stamina of Player variable starts off with max base Stamina as game starts
onready var StaminaRegenLag = STAMINA_REGEN_HOLDUP #Current "Time" remaining until Stamina can start regenerating
# onready var $Player.global_position = World_Info.player_pos

#code for creating hook dectector for player (used for locating a hook to grapple to) [TO BE REPLACED WITH NODE IN EDITOR INSTEAD OF CODE]
var hookDetector = Area2D.new()
var hookDetectorCollision = CollisionShape2D.new()
var hookDetectorShape = CircleShape2D.new()
var hookDetectorRadius = 1000


var hookObjects = []                        #Array containing the hooks the player can grapple to currently
var nearestHook = null                      #Contains reference to the hook object that is currently nearest to the Player
var player_to_hook_vector = Vector2.ZERO    #Vector from player to the hook object
var tangential_vel = Vector2.ZERO           #Vector that is perpendicular to the player_to_hook_vector in direction of swinging
var was_in_grapple = false                  #Denotes whether the player was just in a grapple or not. Used to apply tangential velocity in IN_AIR state right after un-grappling
var was_in_air = false
var player_dir = PlayerDirection.Right
var swingingRight = false                   #Denotes whether player is swinging to the right or not while in grapple state
var swingingLeft = false                    #Denotes whether player is swinging to the left or not while in grapple state
var hookLocked = null                       #Contains reference to hook object that the player is currently attached/locked to
var swing_opp = true   
var normal_to_grapple = Vector2.ZERO
var grapple_len: float 
var in_hurting_state = false

var velocity = Vector2()                    #velocity of the player
var input_vector = Vector2()                #input vector by user

var proj_angle = 0
onready var hook_selector = $HookSelector
func _ready():
  #Code block sets up the collision shape 2D for the hookDetector and connects child to parent
  hookDetectorShape.set_radius(hookDetectorRadius)
  hookDetectorCollision.set_shape(hookDetectorShape)
  hookDetector.add_child(hookDetectorCollision)
  add_child(hookDetector)
   
func _physics_process(delta):
    
  #print(stats.CURRENT_HEALTH)
  #print(velocity)
  #print(World_Info.numOfCollectible)
  #print(player_dir)
  input_vector.x = Input.get_axis("ui_left","ui_right")       #Gets input to left or right
  if(input_vector.x != 0):
    player_dir = PlayerDirection.Left
  if(input_vector.x > 0):
    player_dir = PlayerDirection.Right  
  input_vector.y = Input.get_action_strength("ui_up")         #Gets input up 
  
  update_stamina_objects(delta)                               #Updates everything to do with stamina of the player
   
  hookObjects = hookDetector.get_overlapping_bodies()         #Stores all objects currently detected by player in the 'hookObjects' array
  
  #The following code block removes non-hook objects from the hookObjects array
  var i = hookObjects.size()-1
  for _body in range(hookObjects.size()):
    if (!hookObjects[i].name.begins_with("Hook")):
      hookObjects.remove(i)
    i = i - 1
    
  nearestHook = find_nearest_hook()                #nearestHook now contains reference to the hook that is closest to the player

  match state:                                     #match statement used for state transitioning
    
    PlayerState.Idle:
        #print("Idling")
        velocity.y += GRAVITY*delta                #Player is accelerated downwards by gravity
        stamina_regen(delta)                       #Regenerates stamina        
        update_stamina_objects(delta)              #Updates everything to do with stamina of the player                          
        if(!in_hurting_state):
          velocity.x = 0                             #In IDLE state, the player has no velocity
        state = update_state(state,delta)                #Checks player input and changes or remains in state accordingly
        
    PlayerState.Walk:
        #print("Walking")
        velocity.y += GRAVITY*delta                #Player is accelerated downwards by gravity
        stamina_regen(delta)                       #Regenerates stamina
        update_stamina_objects(delta)              #Updates everything to do with stamina of the player
        #input_vector.x = Input.get_axis("ui_left","ui_right")
        if(!in_hurting_state):
          velocity.x = input_vector.x * MOVE_SPEED   #Player is set a walking speed
        animation.play("Walk")                     #Animation played for walking
        orient_model()                             #Flips player model depending on direction of walk
        state = update_state(state,delta)                #Checks player input and changes or remains in state accordingly
        
    PlayerState.Jump:
        #print("Jumping")
        velocity.y += GRAVITY*delta                #Player is accelerated downwards by gravity
        update_stamina_objects(delta)              #Updates everything to do with stamina of the player   
        animation.play("Jump")                     #Animation played for jumping
        jumpfx.play()                              #Sound played for jumping
        velocity.y = JUMP_FORCE                    #Player up_velocity is set for jump
        state = update_state(state,delta)                #Checks player input and changes or remains in state accordingly
        
    PlayerState.DoubleJump:
        #print("DoubleJumping")
        velocity.y += GRAVITY*delta
        update_stamina_objects(delta)
        animation.play("Jump")
        jumpfx.play()
        velocity.y = JUMP_FORCE
        state = update_state(state,delta) #Checks player input and changes or remains in state accordingly
        
    PlayerState.In_Air:
        #print("In Air")
        stamina_regen(delta)                             #Regenerates stamina
        update_stamina_objects(delta)                    #Updates everything to do with stamina of the player
        if(was_in_grapple):
          velocity = 1.5*tangential_vel
          was_in_grapple = false                         #IF the player was NOT in grapple state before coming to IN_AIR state, then just apply gravity acceleration and horizontal speed according to input
        velocity.y += GRAVITY*delta  
        velocity.x = input_vector.x * MOVE_SPEED
        orient_model()                                   #Flips player model depending on direction of walk
        state = update_state(state,delta)                      #Checks player input and changes or remains in state accordingly
        
    PlayerState.Dash:
        #print("dashing")
        velocity.y += GRAVITY*delta                                           #Player is accelerated downwards by gravity
        stamina -= delta*STAMINA_DRAIN*DASH_STAMINA_CONSUMPTION_MULTIPLIER    #Current Stamina decremented while dashing 
        StaminaRegenLag = STAMINA_REGEN_HOLDUP                                #Stamina regen is stopped, as StaminaRegenLag is reset, have to wait for StaminaRegenLag to become 0 until Stamina can regen again
        update_stamina_objects(delta)                                         #Updates everything to do with stamina of the player
        animation.play("Dash")                                                #Animation played for dash
        if !Dashfx.is_playing():                                              #Playing sound for dash
          Dashfx.play()
        velocity.x = input_vector.x * DASH_FORCE                              #Horizontal velocity set for dash 
        dash_cooldown -= delta                                                #dash_cooldown decremented per frame the dash is performed
        state = update_state(state,delta)                                           #Checks player input and changes or remains in state accordingly
        
    PlayerState.Climb:
        #print("climbing")
        velocity.y += GRAVITY*delta                     #Player is accelerated downwards by gravity
        animation.play("Walk")                          #Animation played for Climb
        velocity.y = -input_vector.y * 450              #Velocity upwards set for player while climbing
        stamina -= delta*STAMINA_DRAIN                  #Current Stamina decremented while climbing
        StaminaRegenLag = STAMINA_REGEN_HOLDUP          #Stamina regen is stopped, as StaminaRegenLag is reset, have to wait for StaminaRegenLag to become 0 until Stamina can regen again
        update_stamina_objects(delta)                   #Updates everything to do with stamina of the player
        state = update_state(state,delta)                     #Checks player input and changes or remains in state accordingly
    PlayerState.Grapple:
      if(hookLocked):                                                          #if the player is attached to a hook currently
        #print("grappling")
        player_to_hook_vector = (hookLocked.global_position)-(global_position) #calculates vector from player to hook
        grapple_len = global_position.distance_to(hookLocked.global_position)  #calculates distance from player to hook
        World_Info.BodyPosition = global_position                              #saves current player position 
        World_Info.HookPosition = hookLocked.global_position                   #saves current hook position
        var angle = get_angle(hookLocked) 
        normal_to_grapple = Vector2(-player_to_hook_vector.y, player_to_hook_vector.x) #calculates the normal vector to vector from player to hook
        
        if(Input.get_axis("ui_left","ui_right")==0):                          #case when no player horizontal input in grapple state, so swinging in the direction it previously was when there was horizontal input
          if(swingingLeft and !swingingRight):
            #print("IN NO INPUT STATE LEFT")
            velocity = -2.5*normal_to_grapple #+ 0.3*player_to_hook_vector
            #print(velocity)
          if(swingingRight and !swingingLeft):
            #print("IN NO INPUT STATE RIGHT")  
            velocity = 2.5*normal_to_grapple #+ 0.3*player_to_hook_vector
            #print(velocity)
          if(was_in_air):
            velocity.y += GRAVITY*delta
              
        if(Input.get_axis("ui_left","ui_right") > 0):
          #print("RIGHT INPUT")                         #case when player input to the right, so swinging right now
          swingingLeft = false
          swingingRight = true
          if(Input.is_action_pressed("ui_up")):
            velocity = 3*normal_to_grapple + 0.5*player_to_hook_vector #0.5*Vector2(0,player_to_hook_vector.y)
          elif(Input.is_action_pressed("ui_down")):
            velocity = 3*normal_to_grapple - 0.5*player_to_hook_vector
          else:  
            velocity = 3*normal_to_grapple #+ 0.05*player_to_hook_vector
        if(Input.get_axis("ui_left","ui_right")< 0):                          #case when player input to the left, so swinging left now
          #print("LEFT INPUT")
          swingingRight = false
          swingingLeft = true
          if(Input.is_action_pressed("ui_up")):
            velocity = -3*normal_to_grapple + 0.5*player_to_hook_vector
          elif(Input.is_action_pressed("ui_down")):
            velocity = -3*normal_to_grapple - 0.5*player_to_hook_vector#0.5*Vector2(0,player_to_hook_vector.y)
          else:  
            velocity = -3*normal_to_grapple #+ 0.05*player_to_hook_vector
        #if(Input.get_action_strength("ui_up")):
        #  velocity = 0.5*player_to_hook_vector  
        #if(Input.get_action_strength("ui_down")):
        #  velocity = -0.5*player_to_hook_vector
               
      state = update_state(state,delta)                                             #Checks player input and changes or remains in state accordingly
  
  handle_collectibles()              #deals with collectibles
  World_Info.tan_vel = velocity 
  World_Info.norm_vec = normal_to_grapple                  
  velocity = move_and_slide(velocity,Vector2.UP)

func update_state(curr_state,delta):
  
  match curr_state: 
    PlayerState.Idle:
      if(!in_hurting_state):
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
      elif(hookObjects.size() > 0 and grapple_pressed() and !is_on_floor()):
        World_Info.init_angle = get_angle(World_Info.selectedHook)
        hookLocked = World_Info.selectedHook
        was_in_air = true
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
        return PlayerState.In_Air        
      else:
        return PlayerState.Climb 
    
    PlayerState.Grapple:
      World_Info.grapple_draw = true
      if(!(grapple_pressed() and hookObjects.size() > 0 and !is_on_floor())):
        World_Info.grapple_draw = false
        hookLocked = null
        tangential_vel = velocity
        was_in_grapple = true
        was_in_air = false
        swingingLeft = false
        swingingRight = false
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
  World_Info.player_health = 4
  if get_tree().reload_current_scene() != OK:
    print("respawn failed")                               

func stamina_regen(delta):
  if(StaminaRegenLag >0 and StaminaRegenLag<=STAMINA_REGEN_HOLDUP): #Counts down until stamina can regen again
    StaminaRegenLag -= delta*STAMINA_REGEN_HOLDUP_COUNTDOWN_FACTOR
  if(StaminaRegenLag <= 0 and stamina <=STAMINA):                   #For case when stamina is ABLE to regen, and stamina is less than full
    stamina += delta*STAMINA_REGEN 

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
    
  
func find_nearest_hook(): 
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


func handle_collectibles():
  var i = 0
  if World_Info.collectible != null:
    $Collectible.play()
    if(stamina < STAMINA):
      stamina = stamina + 20
    #World_Info.currCollectibles.remove(World_Info.collectible.name)
    World_Info.collected_amt = World_Info.collected_amt+1
    World_Info.removedCollectibles.append(World_Info.collectible.name) 
    World_Info.collectible.queue_free()
    World_Info.collectible = null

func _on_Hurtbox_area_entered(_area):
    print("OUCH")
    stats.CURRENT_HEALTH -= 1
    World_Info.player_health = stats.CURRENT_HEALTH
    in_hurting_state = true
    animation.modulate = Color(1,0,0)
    #var rel_pos = global_position - $Hurtbox.get_overlapping_areas()[0].get_parent().global_position
    #if(rel_pos.x > 0):
    #  print("RIGHT")
    velocity = 2000*Vector2(2,-0.65)
    #print("PLAYER OUCH!")
    if stats.CURRENT_HEALTH == 0:
        World_Info.player_pos = World_Info.starter_pos
        respawn()


func _on_Hurtbox_area_exited(area):
  in_hurting_state = false


