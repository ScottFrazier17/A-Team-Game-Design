extends Button

var flag
func _ready():
  flag = 1

func _on_StartGame_mouse_entered():
  $"../../UIHover".play()
  

func _on_Quit_pressed():
  $"../../UIPress".play()
  get_tree().quit()


func _on_StartGame_pressed():
  $"../../UIPress".play()
  TransitionLayer.transition("res://Scenes/World.tscn")


func _on_Options_pressed():
  $"../../UIPress".play()
  #MainMenuMusicController.progress = MainMenuMusicController.getPlayBackPos()
  TransitionLayer.transition("res://Scenes/Options.tscn") # Replace with function body.


func _on_Credits_pressed():
  $"../../UIPress".play()
  TransitionLayer.transition("res://Scenes/Credits.tscn") # Replace with function body.



func _on_LoadGame_mouse_entered():
  $"../../UIPress".play()



func _on_LoadGame_pressed():
  $"../../UIHover".play()



func _on_Options_mouse_entered():
  $"../../UIHover".play()


func _on_Quit_mouse_entered():
  $"../../UIHover".play()


func _on_Credits_mouse_entered():
  $"../../UIHover".play()
