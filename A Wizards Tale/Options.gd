extends Control

func _read():
  MainMenuMusicController.playM()


func _on_OptionsBack_pressed():
  $"../UIPressOptions".play()
  TransitionLayer.transition("res://MainMenu.tscn")


func _on_VolumeSlider_value_changed(value):
  AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), value)



func _on_OptionsBack_mouse_entered():
  $"../UIHoverOptions".play()



func _on_CheckBox_toggled(button_pressed):
  OS.window_fullscreen = !OS.window_fullscreen

