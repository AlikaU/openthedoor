extends Node2D

var velocity = Vector2(1000, 0)  # starts moving right

func _ready():
	# randomly pick warm reds OR pinks/purples
	#var hue = randf_range(0.0, 0.08) if randf() > 0.5 else randf_range(0.85, 1.0)
	var hue = randf_range(0.75, 0.95)

	modulate = Color.from_hsv(hue, randf_range(0.6, 0.8), 1.0)

func _process(delta):
	# nudge velocity randomly each frame — the "wind"
	velocity.x += randf_range(-600, 300) * delta
	velocity.y += randf_range(-1500, 1500) * delta
	
	# clamp so it doesn't go crazy fast or drift backwards
	velocity.x = clamp(velocity.x, 300, 1000)   # always moves right, just faster/slower
	velocity.y = clamp(velocity.y, -1000, 1000)    # limited vertical range
	
	position += velocity * delta
	
	
	# disappear off screen
	var screen = get_viewport_rect().size
	if global_position.x > screen.x + 100:   # buffer past edge
		queue_free()
