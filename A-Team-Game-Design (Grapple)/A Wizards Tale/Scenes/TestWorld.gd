extends Node2D
var hookChildren = []
func _ready():
  $Player.global_position = World_Info.player_pos

func _process(_delta):
  #print(World_Info.paused)
  World_Info.player_pos = $Player.global_position
  #if(Input.is_action_just_pressed("esc")):
  #  World_Info.paused = true
  #  if get_tree().change_scene("res://Scenes/Options.tscn") != OK:
  #    print("Error in changign scene to Options")  
  #print(World_Info.player_pos)
  #print(World_Info.player_vec)
  #print(World_Info.player_pos + 100*World_Info.player_vec)
  #if(Input.is_action_pressed("ui_x")):
  update()
  #print($Hook.get_collision_layer_bit(1))
  #print($Hook.global_position)
  #print($Player.global_position)
  
  hookChildren = get_children()
  var i = hookChildren.size()-1
  for hook in range(hookChildren.size()):
    #print(i)
    if (!hookChildren[i].name.begins_with("Hook")):
      hookChildren.remove(i)
      #print(i)
    i = i - 1
  for hook in hookChildren:
    if hook == World_Info.selectedHook:
      hook.modulate = Color(1,0,0)
    else:
      hook.modulate = Color(1,1,1)  
  

func _draw():
  if(World_Info.grapple_draw == true):
    #draw_line(World_Info.BodyPosition, World_Info.p, Color.red, 8)
    draw_line(World_Info.BodyPosition, World_Info.HookPosition, Color.white, 4)#World_Info.player_pos, World_Info.player_pos+100*World_Info.player_vec,Color.white, 8)      
  else:
    draw_line(Vector2.ZERO, Vector2.ZERO, Color.white, 4)
