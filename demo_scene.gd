extends Node

@onready var start_position := $Marker2D
@onready var player := $Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#player.x = get_viewport().get_visible_rect().size.x/2
	#player.y = get_viewport().get_visible_rect().size.y/2
	pass
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
