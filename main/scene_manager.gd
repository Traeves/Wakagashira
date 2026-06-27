class_name GameSceneManager
extends CanvasLayer

@onready var color_rect:= $ColorRect
@onready var animation_player:= $AnimationPlayer

@export var environment_host: Node2D

# Enum to hold all the game levels
enum GameLevel {
	MAIN_MENU,
	TUTORIAL,
	LEVEL_1,
}

@export var available_levels: Array[PackedScene]

var current_level: Node = null
var current_level_id: GameLevel
var is_transitioning: bool = false

# Dictionary with all our cached scenes
# IMPORTANT: ENUM INTEGER IS KEY
var cached_scenes: Dictionary = {}

func _ready() -> void:
	color_rect.modulate.a = 0
	color_rect.hide()


func load_environment(level_id: GameLevel, anim_name: String = "fade") -> void:
	# Safety checks
	if is_transitioning: return
	if level_id < 0 or level_id >= available_levels.size():
		push_error("Level ID out of bounds! Check available levels array.")
		return
	var target_scene = available_levels[level_id]
	if target_scene == null:
		push_error("No PackedScene assigned in INspector for Level ID: " + str(level_id))
		return
	# Safety checks done
	
	is_transitioning = true
	
	# Fade out
	color_rect.show()
	animation_player.play(anim_name)
	await animation_player.animation_finished
	
	# Suspend the old environment
	if current_level != null:
		environment_host.remove_child(current_level)
	
	# Check scene cache or instaniate for the first time
	if cached_scenes.has(level_id):
		current_level = cached_scenes[level_id]
	else:
		current_level = target_scene.instantiate()
		cached_scenes[level_id] = current_level
	
	# Add the new environment to the active tree
	environment_host.add_child(current_level)
	current_level_id = level_id
	
	# Fade in
	animation_player.play_backwards(anim_name)
	await animation_player.animation_finished
	
	color_rect.hide()
	is_transitioning = false
