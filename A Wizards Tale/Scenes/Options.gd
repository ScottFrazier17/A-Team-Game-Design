extends Control


func _ready():
  $MASTERSlider.value = AudioBusGlobal.Master
  $SFXSlider.value = AudioBusGlobal.sfx
  MainMenuMusicController.playM()

func _on_OptionsBack_pressed():
  $"../UIPressOptions".play()
  AudioBusGlobal.Master = $MASTERSlider.value
  AudioBusGlobal.sfx = $SFXSlider.value
  TransitionLayer.transition("res://Scenes/MainMenu.tscn")

#func _on_VolumeSlider_value_changed(value):
#  AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), value)

func _on_OptionsBack_mouse_entered():
  $"../UIHoverOptions".play()

func _on_CheckBox_toggled(button_pressed):
  OS.window_fullscreen = !OS.window_fullscreen


func _on_MASTERSlider_value_changed(value):
  AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"),value)
  AudioBusGlobal.Master = value
func _on_SFXSlider_value_changed(value):
  AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"),value)
  AudioBusGlobal.sfx = value

func _process(delta):
  if(Input.is_action_just_pressed("esc")):
    get_tree().change_scene("res://Scenes/TestWorld.tscn")

