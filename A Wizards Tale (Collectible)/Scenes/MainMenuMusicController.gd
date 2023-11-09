extends Node2D
#var gameStarted = false  #starts off as false, but gets set to true once game started 
func _ready():
  pass

func mainMenuMusic():
  #$MainMenuMusic.stream = preload("res://Audio/NDKG_CreepyAtmosphere_Looped.wav")
  $MainMenuMusic.play()
  #progress = $MainMenuMusic.get_playback_position()

func getPlayBackPos():
  $MainMenuMusic.get_playback_position()

func playM():
  $MainMenuMusic.play()
