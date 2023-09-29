extends Button

var flag
func _ready():
  flag = 1

func _on_StartGame_mouse_entered():
  #if (flag>0):
    #$"../HoverSound".play(0.0)
  flag = -1
  print(flag)
  
   
  
func _on_StartGame_mouse_exited():
  $"../HoverSound".stop()
  flag = 1


func _on_Quit_pressed():
  get_tree().quit()


func _on_StartGame_pressed():
  #$"../..".hide()
  #get_node("res://MainMenu").free()
  TransitionLayer.transition("res://Level.tscn")



  


func _on_Options_pressed():
  TransitionLayer.transition("res://Options.tscn") # Replace with function body.


func _on_Credits_pressed():
  TransitionLayer.transition("res://Credits.tscn")#pass # Replace with function body.
