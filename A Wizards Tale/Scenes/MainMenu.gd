extends ParallaxBackground

var scroll_vel = 100


func _ready():
  #World_Info.curr_level = "res://Scenes/Level1.tscn"
  MainMenuMusicController.mainMenuMusic()

func _process(delta):
  scroll_offset.x -= scroll_vel*delta
  
func _on_StartGame_pressed():
  #$"../../UIPress".play()
  $UIPress.play()
  #TransitionLayer.transition("res://Scenes/World.tscn")
  #TransitionLayer.transition("res://Scenes/TestWorld.tscn")
  TransitionLayer.transition(World_Info.curr_level)
  


func _on_StartGame_mouse_entered():
  #$"../../UIHover".play()
  $UIHover.play()



func _on_Options_pressed():
  #$"../../UIPress".play()
  $UIPress.play()
  #MainMenuMusicController.progress = MainMenuMusicController.getPlayBackPos()
  TransitionLayer.transition("res://Scenes/Options.tscn")
  

func _on_Options_mouse_entered():
  #$"../../UIHover".play()
  $UIHover.play()


func _on_Quit_pressed():
  #$"../../UIPress".play()
  $UIPress.play()
  get_tree().quit()


func _on_Quit_mouse_entered():
  #$"../../UIHover".play()
  $UIHover.play()

func _on_Credits_pressed():
  #$"../../UIPress".play()
  $UIPress.play()
  TransitionLayer.transition("res://Scenes/Credits.tscn")


func _on_Credits_mouse_entered():
  #$"../../UIHover".play()
  $UIHover.play()
