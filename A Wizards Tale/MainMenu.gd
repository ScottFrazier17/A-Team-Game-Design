extends ParallaxBackground

var scroll_vel = 100

func _process(delta):
  scroll_offset.x -= scroll_vel*delta
  #print(scroll_offset.x)
