extends Area2D




func _on_Collectible_body_entered(body):
  if(body.name == "Player"):
    World_Info.collectible = self
    #World_Info.collectibles_list.append(self)  
