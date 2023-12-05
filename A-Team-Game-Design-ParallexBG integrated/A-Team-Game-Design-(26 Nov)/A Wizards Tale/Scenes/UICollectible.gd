extends Control
onready var label = $Label
var collected_so_far = 0
var max_collectibles = 10
func _process(delta):
  collected_so_far = World_Info.collected_amt
  if(label):
    label.text = str(collected_so_far) + " / " + str(max_collectibles)
