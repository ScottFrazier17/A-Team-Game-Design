extends CharacterBody2D

const SPEED = 300.0
const MAX_SPEED = 300.0
const CROUCH_SPEED = MAX_SPEED/8
const JUMP_VELOCITY = -400.0

var has_double_jump = true
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var wall_normal = get_wall_normal()

@onready var animation = get_node("AnimationPlayer")

func _physics_process(delta):
	
	# Maybe make more functions for each state to better organize code
	
	# Add the gravity.
	if not is_on_floor() and not is_on_wall_only():
		velocity.y += gravity * delta
		
	if is_on_floor():
		has_double_jump = true

	var direction = Input.get_axis("ui_left", "ui_right")
	
	# Left Movement
	if direction == -1:
		get_node("AnimatedSprite2D").flip_h = true
		if velocity.x > MAX_SPEED:
			velocity.x = MAX_SPEED
		elif velocity.x < -MAX_SPEED:
			velocity.x = -MAX_SPEED
		velocity.x += direction * SPEED/10
		
		if Input.is_action_pressed("ui_down") and is_on_floor():
			animation.play("Crouch")
			velocity.x = move_toward(velocity.x, -CROUCH_SPEED, SPEED/5)
		
		elif velocity.x < 0 and is_on_floor():
			animation.play("Run Left")
	
	# Right Movement
	elif direction == 1:
		get_node("AnimatedSprite2D").flip_h = false
		if velocity.x > MAX_SPEED:
			velocity.x = MAX_SPEED
		elif velocity.x < -MAX_SPEED:
			velocity.x = -MAX_SPEED
		velocity.x += direction * SPEED/10
		
		if Input.is_action_pressed("ui_down") and is_on_floor():
			animation.play("Crouch")
			velocity.x = move_toward(velocity.x, CROUCH_SPEED, SPEED/5)
		
		elif velocity.x > 0 and is_on_floor():
			animation.play("Run Right")

	else:
		velocity.x = move_toward(velocity.x, 0, SPEED/8)
		
		if is_on_floor() and not Input.is_action_pressed("ui_down"):
			animation.play("Idle")
	if velocity.y > 0 and not is_on_wall_only():
		animation.play("Fall")

	# Wall Jump
	if is_on_wall_only():
		animation.play("Climb")
		velocity.y = move_toward(velocity.y, MAX_SPEED/2, gravity * delta)
		wall_normal = get_wall_normal()
		
		if wall_normal == Vector2.LEFT and (Input.is_action_just_pressed("ui_select") or Input.is_action_just_pressed("ui_up")):
			velocity.x = wall_normal.x * MAX_SPEED * 2
			velocity.y = JUMP_VELOCITY
			animation.play("Jump")
			print("LEFT\n")
		elif wall_normal == Vector2.RIGHT and (Input.is_action_just_pressed("ui_select") or Input.is_action_just_pressed("ui_up")):
			velocity.x = wall_normal.x * MAX_SPEED * 2
			velocity.y = JUMP_VELOCITY
			print("RIGHT\n")
	
	# Handle Jump.
	if not is_on_wall_only() and (Input.is_action_just_pressed("ui_select") or Input.is_action_just_pressed("ui_up")):
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
			animation.play("Jump")
		elif has_double_jump:
			has_double_jump = false
			velocity.y = JUMP_VELOCITY
			animation.play("Jump")
			


	move_and_slide()
