extends RigidBody2D

@onready var lifetime_timer := $LifetimeTimer

func _ready() -> void:
	lifetime_timer.timeout.connect(_on_lifetime_timer_timeout)
	pass


func _on_lifetime_timer_timeout() -> void:
	queue_free()


func _on_body_entered(body: Node) -> void:
	queue_free()
