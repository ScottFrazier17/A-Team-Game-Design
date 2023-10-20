extends CanvasLayer

func transition(dest_scene : String):
  $AnimationPlayer.play('dissolve')
  yield($AnimationPlayer, "animation_finished")
  get_tree().change_scene(dest_scene)
  $AnimationPlayer.play_backwards('dissolve')
