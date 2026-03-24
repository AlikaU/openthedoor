extends Node

var food: int = 5
var food_timer: float = 0.0
var message_timer: float = 0.0
var game_over: bool = false

const FOOD_DEPLETION_INTERVAL = 1.0
const MESSAGE_DURATION = 4.0
const LOW_FOOD_THRESHOLD = 5
const FOOD_TYPES = ["apples", "carrots", "eggs", "potatoes", "bananas", "tomatoes"]
const ARRIVE_VERBS = ["came home with", "scavenged", "found", "returned with", "brought"]

@onready var foodLabel = $"/root/World/CanvasLayer2/FoodLabel"
@onready var messageLabel = $"/root/World/CanvasLayer2/MessageLabel"

func _ready() -> void:
	GameInput.shiny_entered.connect(_on_shiny_entered)
	GameInput.fluffy_entered.connect(_on_fluffy_entered)
	_update_food_label()

func _process(delta: float) -> void:
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


func _on_shiny_entered() -> void:
	_character_arrived("shiny")

func _on_fluffy_entered() -> void:
	_character_arrived("fluffy")

func _character_arrived(who: String) -> void:
	var amount = randi_range(8, 13)
	var food_type = FOOD_TYPES[randi() % FOOD_TYPES.size()]
	var verb = ARRIVE_VERBS[randi() % ARRIVE_VERBS.size()]
	food += amount
	_update_food_label()
	messageLabel.text = "%s %s %d %s." % [who, verb, amount, food_type]
	message_timer = MESSAGE_DURATION

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
