extends Node

# Call scenes using scene_manager.GameLevel.NAMEOFSCENE
# IMPORTANT: You must also add the scene to the correct index in the packed
# scene array in SceneManager
@onready var scene_manager: GameSceneManager = $SceneManager

func _ready() -> void:
	scene_manager.load_environment(scene_manager.GameLevel.MAIN_MENU)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_capture"):
		toggle_mouse_capture()

	if event.is_action_pressed("switch_scene"):
		if scene_manager.current_level_id == scene_manager.GameLevel.MAIN_MENU:
			scene_manager.load_environment(scene_manager.GameLevel.TUTORIAL)
		else:
			scene_manager.load_environment(scene_manager.GameLevel.MAIN_MENU)

func toggle_mouse_capture() -> void:
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
