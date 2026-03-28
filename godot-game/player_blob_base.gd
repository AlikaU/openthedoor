extends CharacterBody2D


const SPEED = 250.0
const TRACTION = 2 # smaller number -> more slippery

var numTrashCollected = 0

var action_left = "ui_left"
var action_right = "ui_right"
var action_up = "ui_up"
var action_down = "ui_down"

func _physics_process(delta: float) -> void:
	var dir = Vector2.ZERO

	if Input.is_action_pressed(action_right): dir.x += 1
	if Input.is_action_pressed(action_left):  dir.x -= 1
	if Input.is_action_pressed(action_down):  dir.y += 1
	if Input.is_action_pressed(action_up):    dir.y -= 1

	if dir != Vector2.ZERO:
		velocity = dir.normalized() * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * delta * TRACTION)
		velocity.y = move_toward(velocity.y, 0, SPEED * delta * TRACTION)
		
	move_and_slide()
	
	push_things_away()

func push_things_away():
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider is RigidBody2D:
			var push_force = 10.0
			var direction = collision.get_normal() * -1
			collider.apply_central_impulse(direction * push_force)
	
	
func collect_trash():
	numTrashCollected += 1
	scale += Vector2(0.02, 0.02)
	
func vanish():
	$AnimatedSprite2D.play("vanish")
	await $AnimatedSprite2D.animation_finished
	queue_free()
