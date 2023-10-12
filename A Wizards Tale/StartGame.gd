extends Button

var flag
func _ready():
  flag = 1

func _on_StartGame_mouse_entered():
<<<<<<< HEAD
  $"../../UIHover".play()
  

func _on_Quit_pressed():
  $"../../UIPress".play()
=======
  #if (flag>0):
	#$"../HoverSound".play(0.0)
  flag = -1
  print(flag)
  
   
  
func _on_StartGame_mouse_exited():
  $"../HoverSound".stop()
  flag = 1


func _on_Quit_pressed():
>>>>>>> 6c28fa1327aae9954c21ff4483dc7fc4fc57f91d
  get_tree().quit()


func _on_StartGame_pressed():
<<<<<<< HEAD
  $"../../UIPress".play()
  TransitionLayer.transition("res://World.tscn")


func _on_Options_pressed():
  $"../../UIPress".play()
  #MainMenuMusicController.progress = MainMenuMusicController.getPlayBackPos()
=======
  #$"../..".hide()
  #get_node("res://MainMenu").free()
  TransitionLayer.transition("res://World.tscn")



  


func _on_Options_pressed():
>>>>>>> 6c28fa1327aae9954c21ff4483dc7fc4fc57f91d
  TransitionLayer.transition("res://Options.tscn") # Replace with function body.


func _on_Credits_pressed():
<<<<<<< HEAD
  $"../../UIPress".play()
  TransitionLayer.transition("res://Credits.tscn")#pass # Replace with function body.



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
=======
  TransitionLayer.transition("res://Credits.tscn")#pass # Replace with function body.
>>>>>>> 6c28fa1327aae9954c21ff4483dc7fc4fc57f91d
