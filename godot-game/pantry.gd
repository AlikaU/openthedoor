extends Node

var food_timer: float = 0.0
var game_over: bool = false
var starving_overlay: Control

var first_time_home: bool = true
var shiny_first_entry: bool = true
var fluffy_first_entry: bool = true
var shown_food_hint: bool = false
var prev_food: int = -1

const INITIAL_FOOD = 20
const FOOD_DEPLETION_INTERVAL = 1.0
const THRESHOLD_HINT = 20
const THRESHOLD_LOW = 15
const THRESHOLD_LEAVE = 10
const THRESHOLD_URGENT = 5

var food: int = INITIAL_FOOD

const FOOD_TYPES = ["apples", "carrots", "eggs", "potatoes", "bananas", "tomatoes"]
const ARRIVE_VERBS = ["came home with", "scavenged", "found", "returned with", "brought"]

@onready var foodLabel = $"/root/World/CanvasLayer2/FoodLabel"

func _ready() -> void:
	TextManager.message_label = $"/root/World/CanvasLayer2/MessageLabel"
	starving_overlay = $"/root/World/CanvasLayer2/StarvingOverlay"
	$"/root/World/CanvasLayer2/GameOverOverlay/Button".pressed.connect(_on_play_again)
	GameInput.shiny_entered.connect(_on_shiny_entered)
	GameInput.shiny_left.connect(_on_someone_left)
	GameInput.fluffy_entered.connect(_on_fluffy_entered)
	GameInput.fluffy_left.connect(_on_someone_left)
	_update_food_label()
	TextManager.show_now(TextManager.NOBODY_HOME_FIRST)

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
			_update_tint()
			if food < THRESHOLD_HINT and not shown_food_hint:
				shown_food_hint = true
				TextManager.push(TextManager.FOOD_HINT)
			if prev_food >= THRESHOLD_LOW and food < THRESHOLD_LOW:
				TextManager.push(TextManager.FOOD_LOW)
			if prev_food >= THRESHOLD_LEAVE and food < THRESHOLD_LEAVE:
				TextManager.push(TextManager.FOOD_LEAVE)
			if prev_food >= THRESHOLD_URGENT and food < THRESHOLD_URGENT:
				TextManager.push(TextManager.FOOD_URGENT, true)
			prev_food = food
			if food <= 0:
				food = 0
				_trigger_game_over()

func _on_shiny_entered() -> void:
	first_time_home = false
	TextManager.clear_now()
	if shiny_first_entry:
		shiny_first_entry = false
		return
	shiny_first_entry = false
	var amount = randi_range(8, 13)
	var food_type = FOOD_TYPES[randi() % FOOD_TYPES.size()]
	var verb = ARRIVE_VERBS[randi() % ARRIVE_VERBS.size()]
	food += amount
	prev_food = food
	_update_food_label()
	_update_tint()
	TextManager.push("Shiny %s %d %s." % [verb, amount, food_type])

func _on_fluffy_entered() -> void:
	first_time_home = false
	TextManager.clear_now()
	if fluffy_first_entry:
		fluffy_first_entry = false
		return
	fluffy_first_entry = false
	var amount = randi_range(8, 13)
	var food_type = FOOD_TYPES[randi() % FOOD_TYPES.size()]
	var verb = ARRIVE_VERBS[randi() % ARRIVE_VERBS.size()]
	food += amount
	prev_food = food
	_update_food_label()
	_update_tint()
	TextManager.push("Fluffy %s %d %s." % [verb, amount, food_type])

func _on_someone_left() -> void:
	if not GameInput.shiny_in_the_house and not GameInput.fluffy_in_the_house:
		TextManager.show_now(TextManager.NOBODY_HOME)

func _update_food_label() -> void:
	foodLabel.text = "food: %d" % food

func _update_tint() -> void:
	var alpha: float = 0.0
	if food <= THRESHOLD_URGENT:
		alpha = lerp(0.35, 0.55, float(THRESHOLD_URGENT - food) / float(THRESHOLD_URGENT))
	elif food < THRESHOLD_LEAVE:
		alpha = lerp(0.0, 0.35, float(THRESHOLD_LEAVE - food) / float(THRESHOLD_LEAVE - THRESHOLD_URGENT))
	starving_overlay.visible = alpha > 0.0
	starving_overlay.modulate.a = alpha

func _on_play_again() -> void:
	$"/root/World/CanvasLayer2/GameOverOverlay".visible = false
	game_over = false
	food = INITIAL_FOOD
	prev_food = food
	shown_food_hint = false
	_update_food_label()
	starving_overlay.visible = false
	TextManager.clear_now()

func _trigger_game_over() -> void:
	game_over = true
	var victims: Array = []
	if GameInput.shiny_in_the_house:
		victims.append("Shiny")
	if GameInput.fluffy_in_the_house:
		victims.append("Fluffy")
	var who = " and ".join(victims)
	var overlay = $"/root/World/CanvasLayer2/GameOverOverlay"
	overlay.get_node("Label").text = "%s died of starvation." % who
	overlay.visible = true
	TextManager.clear_now()
