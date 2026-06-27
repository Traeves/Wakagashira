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
## How far the sword goes when the mouse is moved.
@export var swing_sensitivity: float = 0.02
## How fast the sword catches up with mouse movement
@export var swing_speed: float = 20.0


@onready var pivot:= $Pivot
@onready var stamina_bar:= $StaminaBar
@onready var player_animations:= $Pivot/AnimatedSprite2D


var current_stamina: float
var captured: bool = false
var mouse_delta: Vector2 = Vector2.ZERO
var target_angle: float = 0.0


func _ready() -> void:
	current_stamina = max_stamina
	stamina_bar.max_value = max_stamina
	stamina_bar.value = current_stamina


func _physics_process(delta: float) -> void:
	# 1. Get the swing distance
	var swing_distance = abs(mouse_delta.x)
	# Deadzone checking to prevent micro jitters from draining stamina
	if swing_distance > swing_deadzone:
		# 2. Drain the stamina according to the swing distance
		drain_swing_stamina(swing_distance)
		# 3. Apply the drag to the target angle
		target_angle += mouse_delta.x * swing_sensitivity
	# If swing distance is zero or too small we regen stamina
	else:
		if current_stamina < max_stamina:
			current_stamina += stamina_regen_rate * delta
			current_stamina = clamp(current_stamina, 0.0, max_stamina)
			stamina_bar.value = current_stamina
	# 3.5 Trigger the sleepy animation if stamina is less than a cutoff (20 for now)
	if current_stamina < 20.0:
		player_animations.play("low_stamina")
	else:
		player_animations.play("default")
		player_animations.stop()
	# 4. Apply the smooth rotation to the sword
	pivot.rotation = lerp_angle(pivot.rotation, target_angle, swing_speed * delta)
	
	
	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_vector("left", "right", "up", "down")
	if direction:
		velocity = direction.normalized() * move_speed * (current_stamina / max_stamina)
	else:
		velocity = Vector2.ZERO
	
	
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
	var total_cost = abs(distance) * swing_stamina_cost
	current_stamina -= total_cost
	current_stamina = clamp(current_stamina, 0.0, max_stamina)
	stamina_bar.value = current_stamina
