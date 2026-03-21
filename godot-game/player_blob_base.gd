extends CharacterBody2D


const SPEED = 450.0
const TRACTION = 4 # smaller number -> more slippery

var numBubblesEaten = 0

func _physics_process(delta: float) -> void:
	# Add the gravity.
	#if not is_on_floor():
		#velocity += get_gravity() * delta

	# Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	#var direction := Input.get_axis("ui_left", "ui_right")
	#if direction:
		#velocity.x = direction * SPEED
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)
		
	var dir = Vector2.ZERO

	if Input.is_action_pressed("ui_right"): dir.x += 1
	if Input.is_action_pressed("ui_left"):  dir.x -= 1
	if Input.is_action_pressed("ui_down"):  dir.y += 1
	if Input.is_action_pressed("ui_up"):    dir.y -= 1

	if dir != Vector2.ZERO:
		velocity = dir.normalized() * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * delta * TRACTION)
		velocity.y = move_toward(velocity.y, 0, SPEED * delta * TRACTION)
		
	move_and_slide()
	
	
func eat_bubble():
	numBubblesEaten += 1
	scale += Vector2(0.02, 0.02)
	
func vanish():
	$AnimatedSprite2D.play("vanish")
	await $AnimatedSprite2D.animation_finished
	queue_free()
