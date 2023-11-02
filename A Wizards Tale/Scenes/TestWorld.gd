extends Node2D

func _ready():
  $Player.global_position = World_Info.player_pos

func _process(_delta):
  World_Info.player_pos = $Player.global_position
  if(Input.is_action_just_pressed("esc")):
    var _scene = get_tree().change_scene("res://Scenes/Options.tscn")  
