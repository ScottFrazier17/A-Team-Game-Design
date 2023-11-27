extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var poison_spike_scene = preload("res://Enemies/PoisonSpike.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
  $Player.global_position = World_Info.starter_pos
  var poison_spike_instance = poison_spike_scene.instance()
  get_tree().current_scene.add_child(poison_spike_instance)
  poison_spike_instance.global_position = $"Orange Slime".global_position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
  pass
