extends Node2D

const Shiny = preload("res://shiny.tscn")
const Fluffy = preload("res://fluffy.tscn")

var blob_instances = {"shiny": null, "fluffy": null}
var blob_scenes = {}

var food: int = 5
var food_timer: float = 0.0
var message_timer: float = 0.0
var game_over: bool = false

const FOOD_DEPLETION_INTERVAL = 1.0
const MESSAGE_DURATION = 4.0
const LOW_FOOD_THRESHOLD = 5
const FOOD_TYPES = ["apples", "carrots", "eggs", "potatoes", "bananas", "tomatoes"]
const ARRIVE_VERBS = ["came home with", "scavenged", "found", "returned with", "brought"]

@onready var debugLabel = $CanvasLayer/DebugLabel
@onready var foodLabel = $CanvasLayer2/FoodLabel
@onready var messageLabel = $CanvasLayer2/MessageLabel

func _ready() -> void:
	blob_scenes = {"shiny": Shiny, "fluffy": Fluffy}
	GameInput.shiny_entered.connect(_on_shiny_entered)
	GameInput.shiny_left.connect(_on_shiny_left)
	GameInput.fluffy_entered.connect(_on_fluffy_entered)
	GameInput.fluffy_left.connect(_on_fluffy_left)
	GameInput.debug_toggled.connect(_on_debug_toggled)
	_update_food_label()
	messageLabel.text = "TEST MESSAGE"

func _process(delta: float) -> void:
	if debugLabel.visible:
		var home = []
		if GameInput.shiny_in_the_house: home.append("shiny")
		if GameInput.fluffy_in_the_house: home.append("fluffy")
		var who = "" if home else "nobody is home"
		var door_status = "open" if GameInput.door_open else "closed"
		debugLabel.text = "door: %s\n%s\n" % [door_status, who]

	if game_over:
		return

	var someone_home = GameInput.shiny_in_the_house or GameInput.fluffy_in_the_house

	if someone_home:
		food_timer += delta
		if food_timer >= FOOD_DEPLETION_INTERVAL:
			food_timer -= FOOD_DEPLETION_INTERVAL
			food -= 1
			_update_food_label()
			if food <= 0:
				food = 0
				_trigger_game_over()
				return

	if message_timer > 0:
		message_timer -= delta
		if message_timer <= 0:
			message_timer = 0
			_update_message()
	else:
		_update_message()


func _update_food_label() -> void:
	foodLabel.text = "food: %d" % food


func _update_message() -> void:
	var someone_home = GameInput.shiny_in_the_house or GameInput.fluffy_in_the_house
	if food < LOW_FOOD_THRESHOLD and someone_home:
		messageLabel.text = "don't starve at home! find something to eat outside."
	else:
		messageLabel.text = ""


func _trigger_game_over() -> void:
	game_over = true
	var victim = "fluffy" if GameInput.fluffy_in_the_house else "shiny"
	messageLabel.text = "game over. %s died of starvation." % victim


func _on_debug_toggled():
	debugLabel.visible = !debugLabel.visible

func _on_shiny_entered():
	spawn_blob("shiny")
	_character_arrived("shiny")

func _on_shiny_left():
	despawn_blob("shiny")

func _on_fluffy_entered():
	spawn_blob("fluffy")
	_character_arrived("fluffy")

func _on_fluffy_left():
	despawn_blob("fluffy")

func _character_arrived(who: String) -> void:
	var amount = randi_range(8, 13)
	var food_type = FOOD_TYPES[randi() % FOOD_TYPES.size()]
	var verb = ARRIVE_VERBS[randi() % ARRIVE_VERBS.size()]
	food += amount
	_update_food_label()
	messageLabel.text = "%s %s %d %s." % [who, verb, amount, food_type]
	message_timer = MESSAGE_DURATION

func toggle_blob(id):
	if blob_instances[id] != null:
		despawn_blob(id)
	else:
		spawn_blob(id)

func spawn_blob(id):
	if blob_instances[id] != null:
		return
	var existing = get_node_or_null("dying_blob_" + id)
	if existing:
		existing.queue_free()
	var blob = blob_scenes[id].instantiate()
	blob.position = $SpawnPoint.position
	add_child(blob)
	blob_instances[id] = blob

func despawn_blob(id):
	if blob_instances[id] == null:
		return
	var dying = blob_instances[id]
	blob_instances[id] = null
	dying.name = "dying_blob_" + id
	dying.vanish()
