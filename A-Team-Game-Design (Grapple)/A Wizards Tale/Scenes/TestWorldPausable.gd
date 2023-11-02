extends Node2D
class_name Pauser

signal toggle_pause(paused)
var pause:bool = false setget _set_pause,_get_pause

func _get_pause():
    return pause

func _set_pause(x):
    pause = x
    get_tree().paused = !pause
    emit_signal("toggle_pause",pause)  

# Called when the node enters the scene tree for the first time.
func _process(_delta):
  if(Input.is_action_just_pressed("esc")):
    pause = !pause
