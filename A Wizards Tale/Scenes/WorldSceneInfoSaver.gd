extends Node

#Starting Positions for
  #Level 1 = (206,536)
  #Level 2 = (250,250)
  #Level 3 = (10,0)
var starter_pos = Vector2(206,536)#0,0)#250,250)#10,0)#0,0)#206,536)#3500,0)#206,536)#750,-1250)#750,-3000))#206,536)
var player_pos = starter_pos
var HookPosition = Vector2.ZERO
var BodyPosition = Vector2.ZERO
var fullscreen = false
var paused = false
var selectedHook = null 
var grapple_draw = false
var init_angle:float
var lockHookObj = null
var collectible = null
var collected_amt = 0
var removedCollectibles = []
#var collectibles_list = []
var player_health = 4
var curr_level = "res://Scenes/Level1.tscn"
var at_portal = false
#Remove these variables after testing ---
var tan_vel = Vector2.ZERO
var norm_vec = Vector2.ZERO

var poison_spike_dir = Vector2.ZERO
var slime_to_player = Vector2.ZERO
var spike_range_multiplier = 0
var orange_slime_pos = Vector2.ZERO
