extends CanvasLayer

func transition(dest_scene : String):
  $AnimationPlayer.play('dissolve')
  yield($AnimationPlayer, "animation_finished")
  if get_tree().change_scene(dest_scene) != OK:
    print("Error in transitioning in transition layer")
  $AnimationPlayer.play_backwards('dissolve')
