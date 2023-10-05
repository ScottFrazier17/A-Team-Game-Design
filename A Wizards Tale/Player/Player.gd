extends KinematicBody2D

var GRAVITY = ProjectSettings.get_setting("physics/2d/default_gravity")

const MOVE_SPEED = 1500
const JUMP_FORCE = -1500
const DASH_FORCE = 20000

onready var animationPlayer = $AnimationPlayer
onready var animation = get_node("AnimatedSprite")

var velocity = Vector2()
var can_double_jump = false
var dash_cooldown = 1.0
var is_dashing = false

func _physics_process(delta):
	# Gravity
	velocity.y += GRAVITY * 4 * delta
	
	# Player input
	var input_vector = Vector2()
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")

	if input_vector.x != 0:
		get_node("AnimatedSprite").flip_h = input_vector.x < 0

	# Move the player
	velocity.x = input_vector.x * MOVE_SPEED

	if velocity.x != 0 and is_on_floor():
		animation.play("Walk")
	
	# Dash input handling
	if Input.is_action_just_pressed("ui_select") and !is_dashing:
		dash(input_vector.x)
	
	# Jump input handling
	if is_on_floor():
		can_double_jump = true
		if Input.is_action_just_pressed("ui_up"):
			jump()
	elif can_double_jump and Input.is_action_just_pressed("ui_up"):
		double_jump()
	
	# Perform the dash
	if is_dashing:
		velocity += input_vector * DASH_FORCE * delta
		dash_cooldown -= delta
		if dash_cooldown <= 0:
			is_dashing = false
	
	# Apply movement
	velocity = move_and_slide(velocity, Vector2(0, -1))

func jump():
	velocity.y = JUMP_FORCE
	print("Jumping")
	animation.play("Jump")

func double_jump():
	if can_double_jump:
		print("Double Jumping")
		velocity.y = JUMP_FORCE
		animation.play("Jump")
		can_double_jump = false

func dash(direction):
	is_dashing = true
	dash_cooldown = 1.0
	print("Dashing")
	animation.play("Dash")
	velocity.x = direction * DASH_FORCE

