extends Control

func _ready():
  visible = false

func _process(_delta):
  if Input.is_action_just_pressed("esc"):
    _on_Resume_pressed()
  #print(World_Info.paused)

func _on_Resume_pressed():
  var paused = !get_tree().paused
  get_tree().paused = paused
  visible = paused
  World_Info.paused = paused


func _on_Settings_pressed():
  World_Info.paused = true
  get_tree().paused = false
  if get_tree().change_scene("res://Scenes/Options.tscn") != OK:
    print("Error in changign scene to Options")


func _on_ExitToMenu_pressed():
  World_Info.paused = false
  get_tree().paused = false
  get_tree().change_scene("res://Scenes/MainMenu.tscn")
