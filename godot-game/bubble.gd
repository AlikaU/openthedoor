extends Node2D

var velocity = Vector2(300, 0)  # starts moving right

func _ready():
	# randomly pick warm reds OR pinks/purples
	#var hue = randf_range(0.0, 0.08) if randf() > 0.5 else randf_range(0.85, 1.0)
	var hue = randf_range(0.75, 0.95)

	modulate = Color.from_hsv(hue, randf_range(0.6, 0.8), 1.0)

func _process(delta):
	# nudge velocity randomly each frame — the "wind"
	velocity.x += randf_range(-300, 150) * delta
	velocity.y += randf_range(-500, 500) * delta
	
	# clamp so it doesn't go crazy fast or drift backwards
	velocity.x = clamp(velocity.x, 150, 300)   # always moves right, just faster/slower
	velocity.y = clamp(velocity.y, -300, 300)    # limited vertical range
	
	position += velocity * delta
	
	
	# disappear off screen
	var screen = get_viewport_rect().size
	if global_position.x > screen.x + 50:   # buffer past edge
		queue_free()
		
func _on_body_entered(body):
	print("is player: ", body.is_in_group("player"))
	if body.is_in_group("player"):
		body.eat_bubble()
		queue_free()
