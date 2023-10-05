extends Control





func _on_CreditsBack_pressed():
  $"../UIPressCredits".play()
  TransitionLayer.transition("res://MainMenu.tscn")#pass # Replace with function body.


func _on_CreditsBack_mouse_entered():
  $"../UIHoverCredits".play()
