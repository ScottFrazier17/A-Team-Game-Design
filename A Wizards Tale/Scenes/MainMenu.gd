extends ParallaxBackground

var scroll_vel = 100

func _ready():
  MainMenuMusicController.mainMenuMusic()

func _process(delta):
  scroll_offset.x -= scroll_vel*delta
