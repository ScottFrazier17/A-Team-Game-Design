extends KinematicBody2D
var dir: Vector2

var velocity = Vector2.ZERO



# Called when the node enters the scene tree for the first time.
func _ready():
  #dir = World_Info.poison_spike_dir
  velocity = 20*Vector2(-1,-1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
  #print(velocity)
  move_and_collide(velocity)
