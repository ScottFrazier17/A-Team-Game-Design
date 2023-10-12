extends Control

<<<<<<< HEAD
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

=======



func _on_OptionsBack_pressed():
  TransitionLayer.transition("res://MainMenu.tscn")
>>>>>>> 6c28fa1327aae9954c21ff4483dc7fc4fc57f91d
