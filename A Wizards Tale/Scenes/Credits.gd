extends Control

func _on_CreditsBack_pressed():
  $"../UIPressCredits".play()
  TransitionLayer.transition("res://Scenes/MainMenu.tscn")

func _on_CreditsBack_mouse_entered():
  $"../UIHoverCredits".play()
