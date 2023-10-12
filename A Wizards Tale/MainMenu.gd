extends ParallaxBackground

var scroll_vel = 100

<<<<<<< HEAD
func _ready():
  MainMenuMusicController.mainMenuMusic()

func _process(delta):
  scroll_offset.x -= scroll_vel*delta
  #print(scroll_offset.x)

=======
func _process(delta):
  scroll_offset.x -= scroll_vel*delta
  #print(scroll_offset.x)
>>>>>>> 6c28fa1327aae9954c21ff4483dc7fc4fc57f91d
