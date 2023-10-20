extends KinematicBody2D

const MOVE_SPEED = 1500
const JUMP_FORCE = -1500

var GRAVITY = ProjectSettings.get_setting("physics/2d/default_gravity")
var velocity = Vector2()
var has_double_jump = false

onready var animation = $AnimatedSprite

func _physics_process(delta):
	
	# Gravity
	velocity.y += GRAVITY * 4 * delta
	animation.play("Idle")

	velocity = move_and_slide(velocity, Vector2(0, -1))
