extends Node2D
var hookChildren = []

func _ready():
  $Player.global_position = World_Info.player_pos
  
func _process(_delta):
  World_Info.player_pos = $Player.global_position
  update()
 
  hookChildren = get_children()
  var i = hookChildren.size()-1
  for hook in range(hookChildren.size()):
    if (!hookChildren[i].name.begins_with("Hook")):
      hookChildren.remove(i)
    i = i - 1
  for hook in hookChildren:
    if hook == World_Info.selectedHook:
      hook.modulate = Color(1,0,0)
    else:
      hook.modulate = Color(1,1,1)  
  

func _draw():
  if(World_Info.grapple_draw == true):
    draw_line(World_Info.BodyPosition, World_Info.HookPosition, Color.white, 4)     
  else:
    draw_line(Vector2.ZERO, Vector2.ZERO, Color.white, 4)
