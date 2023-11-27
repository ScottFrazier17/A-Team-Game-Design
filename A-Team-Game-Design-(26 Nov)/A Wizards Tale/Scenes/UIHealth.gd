extends Control

onready var H1 = $Heart1
onready var H2 = $Heart2
onready var H3 = $Heart3
onready var H4 = $Heart4

func _ready():
  H1.value = 1
  H2.value = 1
  H3.value = 1
  H4.value = 1

func _process(_delta):
  if(World_Info.player_health == 4):
    H1.value = 1
    H2.value = 1
    H3.value = 1
    H4.value = 1
  if(World_Info.player_health == 3):
    H1.value = 1
    H2.value = 1
    H3.value = 1
    H4.value = 0
  if(World_Info.player_health == 2):
    H1.value = 1
    H2.value = 1
    H3.value = 0
    H4.value = 0
  if(World_Info.player_health == 1):
    H1.value = 1
    H2.value = 0
    H3.value = 0
    H4.value = 0    
  if(World_Info.player_health == 0):
    H1.value = 0
    H2.value = 0
    H3.value = 0
    H4.value = 0
