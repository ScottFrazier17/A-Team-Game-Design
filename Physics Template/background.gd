extends ParallaxBackground

const SCROLLING_SPEED = 100

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	scroll_offset.x -= SCROLLING_SPEED * delta
