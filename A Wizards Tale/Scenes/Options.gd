extends Control
var x = false
var y = false
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
    #TransitionLayer.transition("res://Scenes/TestWorld.tscn")
    TransitionLayer.transition(World_Info.curr_level)  


func _on_OptionsBack_mouse_entered():
  $"../UIHoverOptions".play()


func _on_CheckBox_toggled(_button_pressed):
  World_Info.fullscreen = !World_Info.fullscreen 
  OS.window_fullscreen = !OS.window_fullscreen
  

func _on_MASTERSlider_value_changed(value):
  AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"),value)
  if(y):
    $SfxSliderAudio.play()  
  AudioBusGlobal.Master = value
  y = true
  
  
func _on_SFXSlider_value_changed(value):
  AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"),value)
  if(x):
    $SfxSliderAudio.play()
  AudioBusGlobal.sfx = value
  x = true


func _process(_delta):
  if(Input.is_action_just_pressed("esc")):
    World_Info.paused = false
    if get_tree().change_scene(World_Info.curr_level) != OK:
      print("Error in changing scene to TestWorld")




