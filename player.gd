extends CharacterBody2D


@export var move_speed = 200.0
@export var max_stamina: float = 100.0
@export var stamina_regen_rate: float = 20.0
@export var swing_stamina_cost: float = 0.15
@export var swing_reduction: float = 10.0

@onready var sword := $Sword
@onready var stamina_bar := $StaminaBar


var current_stamina: float
var last_mouse_position : Vector2

func _ready() -> void:
	current_stamina = max_stamina
	
	stamina_bar.max_value = max_stamina
	stamina_bar.value = current_stamina
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	# 1. Get the mouse movement vector
	var mouse_movement = get_mouse_direction()
	# 2. Get the magnitude of the swing using .length()
	var swing_distance = mouse_movement.length()
	
	# 3. Apply the stamina drain or stamina regen
	# We check if swing distance is greater than 1.0 to avoid swining from mouse "jitters"
	if swing_distance > 1.0:
		drain_swing_stamina(swing_distance)
	else:
		if current_stamina < max_stamina:
			current_stamina += stamina_regen_rate * delta
			current_stamina = clamp(current_stamina, 0.0, max_stamina)
			stamina_bar.value = current_stamina
	
	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_vector("left", "right", "up", "down")
	if direction:
		print(direction)
		velocity = direction.normalized() * move_speed * (current_stamina / max_stamina)
	else:
		velocity = Vector2.ZERO
	

	sword.rotation += mouse_movement.x * delta
	
	
	move_and_slide()


func get_mouse_direction() -> Vector2:
	var new_mouse_position = get_viewport().get_mouse_position()/4.0
	var mouse_movement = new_mouse_position - last_mouse_position
	print(mouse_movement)
	last_mouse_position = new_mouse_position
	return mouse_movement


func drain_swing_stamina(distance : float) -> void:
	var total_cost = distance * swing_stamina_cost
	
	current_stamina -= total_cost
	current_stamina = clamp(current_stamina, 0.0, max_stamina)
	
	stamina_bar.value = current_stamina
