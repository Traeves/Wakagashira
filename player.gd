extends CharacterBody2D

## How fast the player moves.
@export var move_speed = 400.0
## How much max stamina the player has.
@export var max_stamina: float = 100.0
## How sensitive the mouse is (Greater values mean less sensitive).
@export var swing_deadzone: float = 2.0
## How fast the player's stamina regenerates.
@export var stamina_regen_rate: float = 20.0
## A constant to multiply the mouse movement by to determine the stamina cost of a swing.
@export var swing_stamina_cost: float = 0.15


@onready var sword := $Sword
@onready var stamina_bar := $StaminaBar


var current_stamina: float
var mouse_direction : Vector2
var captured : bool = false
var mouse_delta: Vector2 = Vector2.ZERO


func _ready() -> void:
	current_stamina = max_stamina
	stamina_bar.max_value = max_stamina
	stamina_bar.value = current_stamina


func _physics_process(delta: float) -> void:
	var swing_distance
	# 1. Get the mouse movement delta since last frame
	if abs(mouse_delta) > Vector2.ONE * swing_deadzone:
		swing_distance = mouse_delta.x
		mouse_delta = Vector2.ZERO
	else:
		swing_distance = 0
	
	# 2. Apply the stamina drain or stamina regen
	if swing_distance:
		drain_swing_stamina(swing_distance)
	else:
		if current_stamina < max_stamina:
			current_stamina += stamina_regen_rate * delta
			current_stamina = clamp(current_stamina, 0.0, max_stamina)
			stamina_bar.value = current_stamina
	
	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_vector("left", "right", "up", "down")
	if direction:
		velocity = direction.normalized() * move_speed * (current_stamina / max_stamina)
	else:
		velocity = Vector2.ZERO
	
	sword.rotation += swing_distance * delta
	
	
	move_and_slide()


func _input(event):
	if event.is_action_pressed("toggle_capture"):
		toggle_mouse_capture()


func toggle_mouse_capture() -> void:
	if captured:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	captured = !captured


func _unhandled_input(event: InputEvent) -> void:
	# Check if the movement is mouse
	if event is InputEventMouseMotion:
		mouse_delta = event.relative


func drain_swing_stamina(distance: float) -> void:
	var total_cost = distance * swing_stamina_cost
	current_stamina -= total_cost
	current_stamina = clamp(current_stamina, 0.0, max_stamina)
	stamina_bar.value = current_stamina
