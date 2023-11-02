extends CanvasLayer

func transition(dest_scene : String):
  $AnimationPlayer.play('dissolve')
  yield($AnimationPlayer, "animation_finished")
  var _scene = get_tree().change_scene(dest_scene)
  $AnimationPlayer.play_backwards('dissolve')
