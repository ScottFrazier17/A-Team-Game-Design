extends Node2D
var hookChildren = []
var collectibleChildren = []
var is_ending_lvl = false
func _ready():
  $Player.global_position = World_Info.player_pos
  for collectible in get_children():
    if(collectible.name.begins_with("Collectible")):
      collectibleChildren.append(collectible)
  if(World_Info.removedCollectibles.size()):
    for rem_collectible in World_Info.removedCollectibles:
      for collectible in collectibleChildren:
        if(collectible.name == rem_collectible):
          collectible.queue_free()
func _process(_delta):
  #print($Player.global_position)
  #print($Portal.global_position)
  if($Portal/Area2D.overlaps_body($Player) and World_Info.collected_amt == 10):
    World_Info.collected_amt = 0
    is_end_of_level()
  if(!is_ending_lvl):
    World_Info.player_pos = $Player.global_position
  update()
 
  hookChildren = get_children()
  var i = hookChildren.size()-1
  for _hook in range(hookChildren.size()):
    if (!hookChildren[i].name.begins_with("Hook")):
      hookChildren.remove(i)
    i = i - 1
  for hook in hookChildren:
    if hook == World_Info.selectedHook:
      hook.modulate = Color(1,0,0)
    else:
      hook.modulate = Color(1,1,1)  
  #print(World_Info.player_health)

func _draw():
  if(World_Info.grapple_draw == true):
    draw_line(World_Info.BodyPosition, World_Info.HookPosition, Color.white, 4)
    #draw_line(World_Info.BodyPosition, World_Info.BodyPosition+World_Info.tan_vel, Color.red, 4)
    #draw_line(World_Info.BodyPosition, World_Info.BodyPosition+World_Info.norm_vec, Color.yellow,4)     
  else:
    draw_line(Vector2.ZERO, Vector2.ZERO, Color.white, 4)
    
func is_end_of_level():
  is_ending_lvl = true
  World_Info.curr_level = "res://Scenes/Level2.tscn"
  World_Info.starter_pos = Vector2(230,250)
  World_Info.player_pos = Vector2(230,250)
  World_Info.removedCollectibles = []
  TransitionLayer.transition(World_Info.curr_level)    
