extends Control

func _ready():
  get_tree().paused = false
  $MASTERSlider.value = AudioBusGlobal.Master  
  $SFXSlider.value = AudioBusGlobal.sfx
  #MainMenuMusicController.playM()
  $CheckBox.set_pressed_no_signal(World_Info.fullscreen)
  
  
func _on_OptionsBack_pressed():
  $"../UIPressOptions".play()
  AudioBusGlobal.Master = $MASTERSlider.value
  AudioBusGlobal.sfx = $SFXSlider.value
  if(World_Info.paused==false):
    TransitionLayer.transition("res://Scenes/MainMenu.tscn")
  if(World_Info.paused == true):
    World_Info.paused = false
    TransitionLayer.transition("res://Scenes/TestWorld.tscn")  


func _on_OptionsBack_mouse_entered():
  $"../UIHoverOptions".play()


func _on_CheckBox_toggled(_button_pressed):
  World_Info.fullscreen = !World_Info.fullscreen 
  OS.window_fullscreen = !OS.window_fullscreen
  

func _on_MASTERSlider_value_changed(value):
  AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"),value)
  AudioBusGlobal.Master = value
  
  
func _on_SFXSlider_value_changed(value):
  AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"),value)
  AudioBusGlobal.sfx = value


func _process(_delta):
  if(Input.is_action_just_pressed("esc")):
    World_Info.paused = false
    if get_tree().change_scene("res://Scenes/TestWorld.tscn") != OK:
      print("Error in changing scene to TestWorld")

