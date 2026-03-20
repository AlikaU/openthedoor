extends Node2D

const PlayerBlob1 = preload("res://player_blob_1.tscn")
const PlayerBlob2 = preload("res://player_blob_2.tscn")

var blob_instances = {1: null, 2: null}
var blob_scenes = {}

@onready var doorOpenLabel = $CanvasLayer/DoorLabel
@onready var eatenBubblesCountLabel = $CanvasLayer/EatenBubbleCountLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	blob_scenes = {1: PlayerBlob1, 2: PlayerBlob2}

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	doorOpenLabel.text = "door open: " + str(DoorInput.door_open)
	if blob_instances[1] != null:
		eatenBubblesCountLabel.text = "bubbles eaten: " + str(blob_instances[1].numBubblesEaten)

	if Input.is_action_just_pressed("spawn_blob1"):
		toggle_blob(1)
	if Input.is_action_just_pressed("spawn_blob2"):
		toggle_blob(2)

func toggle_blob(id):
	if blob_instances[id] != null:
		despawn_blob(id)
	else:
		spawn_blob(id)

func spawn_blob(id):
	# kill any dying blob that's still in the tree
	var existing = get_node_or_null("dying_blob_" + str(id))
	if existing:
		existing.queue_free()
	var blob = blob_scenes[id].instantiate()
	blob.position = $SpawnPoint.position
	add_child(blob)
	blob_instances[id] = blob

func despawn_blob(id):
	var dying = blob_instances[id]
	blob_instances[id] = null
	dying.name = "dying_blob_" + str(id)  # rename so we can find it later
	dying.vanish()
