extends Area2D


func _on_SetOfSpikes_body_entered(body):
  if(body.has_method("respawn")):
    body.respawn()
