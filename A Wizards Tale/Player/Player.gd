extends KinematicBody2D

const MOVE_SPEED = 1500
const JUMP_FORCE = -1500
const DASH_FORCE = 3000

var GRAVITY = ProjectSettings.get_setting("physics/2d/default_gravity")
var velocity = Vector2()
var has_double_jump = false
var has_dash = false

onready var animationPlayer = $AnimationPlayer
onready var animation = get_node("AnimatedSprite")

func _physics_process(delta):
	# Gravity
	velocity.y += GRAVITY * 4 * delta

	# Player input
	var input_vector = Vector2()
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")

	# Move the player
	velocity.x = input_vector.x * MOVE_SPEED
	
	if velocity.x != 0 and is_on_floor():
			animation.play("Walk")

	if is_on_floor():
		# Player is on the ground
		has_double_jump = true
		has_dash = true
		
		if velocity.x == 0:
			animation.play("Idle") 
		if Input.is_action_just_pressed("ui_up"):
			animation.play("Jump")
			velocity.y = JUMP_FORCE
			
	if Input.is_action_just_pressed("ui_up") and has_double_jump:
		# Player can perform a double jump
			print("Double Jumping")
			animation.play("Jump")
			velocity.y = JUMP_FORCE
			has_double_jump = false
	if has_dash:
		if Input.is_action_just_pressed("ui_select"):
			print("Dashing")
			animation.play("Dash")
			velocity.x += DASH_FORCE
			has_dash = false
			

	velocity = move_and_slide(velocity, Vector2(0, -1))

	# Flip the player sprite based on movement direction
	if input_vector.x != 0:
		get_node("AnimatedSprite").flip_h = input_vector.x < 0
	
	
