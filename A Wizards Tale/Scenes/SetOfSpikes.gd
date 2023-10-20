extends Area2D


func _on_SetOfSpikes_body_entered(body):
  if(body.has_method("respawn")):
    World_Info.player_pos = World_Info.starter_pos
    body.respawn()
