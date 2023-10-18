extends Node2D

#/var mainMenuMusic = load("res://Audio/NDKG_CreepyAtmosphere_Looped.wav")
#var progress = 1;
func _ready():
  pass
  

func mainMenuMusic():
  $MainMenuMusic.stream = preload("res://Audio/NDKG_CreepyAtmosphere_Looped.wav")
  $MainMenuMusic.play()
  #progress = $MainMenuMusic.get_playback_position()

func getPlayBackPos():
  $MainMenuMusic.get_playback_position()

func playM():
  $MainMenuMusic.play()
