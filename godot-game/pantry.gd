extends Node

var food: int = 35
var food_timer: float = 0.0
var game_over: bool = false
var tint_overlay: ColorRect

var first_time_home: bool = true
var shiny_first_entry: bool = true
var fluffy_first_entry: bool = true
var shown_food_hint: bool = false
var shown_food_low: bool = false
var shown_food_leave: bool = false
var shown_food_urgent: bool = false

const FOOD_DEPLETION_INTERVAL = 1.0
const THRESHOLD_HINT = 30
const THRESHOLD_LOW = 20
const THRESHOLD_LEAVE = 12
const THRESHOLD_URGENT = 8

const FOOD_TYPES = ["apples", "carrots", "eggs", "potatoes", "bananas", "tomatoes"]
const ARRIVE_VERBS = ["came home with", "scavenged", "found", "returned with", "brought"]

@onready var foodLabel = $"/root/World/CanvasLayer2/FoodLabel"

func _ready() -> void:
	TextManager.message_label = $"/root/World/CanvasLayer2/MessageLabel"
	GameInput.shiny_entered.connect(_on_shiny_entered)
	GameInput.shiny_left.connect(_on_someone_left)
	GameInput.fluffy_entered.connect(_on_fluffy_entered)
	GameInput.fluffy_left.connect(_on_someone_left)
	_setup_tint()
	_update_food_label()
	TextManager.show_now(TextManager.NOBODY_HOME_FIRST)

func _setup_tint() -> void:
	var canvas = $"/root/World/CanvasLayer2"
	tint_overlay = ColorRect.new()
	tint_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	tint_overlay.color = Color(0.4, 0.05, 0.1, 0.0)
	tint_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(tint_overlay)
	canvas.move_child(tint_overlay, 1)

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
			elif food < THRESHOLD_LOW and not shown_food_low:
				shown_food_low = true
				TextManager.push(TextManager.FOOD_LOW)
			elif food < THRESHOLD_LEAVE and not shown_food_leave:
				shown_food_leave = true
				TextManager.push(TextManager.FOOD_LEAVE)
			elif food < THRESHOLD_URGENT and not shown_food_urgent:
				shown_food_urgent = true
				TextManager.push(TextManager.FOOD_URGENT, true)
			if food <= 0:
				food = 0
				_trigger_game_over()

func _on_shiny_entered() -> void:
	first_time_home = false
	TextManager.clear_now()
	var amount = randi_range(8, 13)
	var food_type = FOOD_TYPES[randi() % FOOD_TYPES.size()]
	var verb = ARRIVE_VERBS[randi() % ARRIVE_VERBS.size()]
	food += amount
	_update_food_label()
	_update_tint()
	if not shiny_first_entry:
		TextManager.push("Shiny %s %d %s." % [verb, amount, food_type])
	shiny_first_entry = false

func _on_fluffy_entered() -> void:
	first_time_home = false
	TextManager.clear_now()
	var amount = randi_range(8, 13)
	var food_type = FOOD_TYPES[randi() % FOOD_TYPES.size()]
	var verb = ARRIVE_VERBS[randi() % ARRIVE_VERBS.size()]
	food += amount
	_update_food_label()
	_update_tint()
	if not fluffy_first_entry:
		TextManager.push("Fluffy %s %d %s." % [verb, amount, food_type])
	fluffy_first_entry = false

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
	tint_overlay.color.a = alpha

func _trigger_game_over() -> void:
	game_over = true
	var victim = "fluffy" if GameInput.fluffy_in_the_house else "shiny"
	TextManager.show_now(TextManager.GAME_OVER % victim.capitalize())
