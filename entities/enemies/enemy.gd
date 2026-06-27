extends CharacterBody2D


@export var reload_time: float = 1.0
@export var turn_speed: float = 0.1
@export var trigger_happiness: float = 0.01
@export var bullet_speed: float = 1000.0
@export var bullet_scene: PackedScene
@export var max_health: int = 100


@onready var detection_area:= $Pivot/DetectionArea
@onready var pivot:= $Pivot
@onready var muzzle:= $Pivot/Muzzle
@onready var reload_timer:= $ReloadTimer
@onready var healthbar:= $HealthBar
@onready var enemy_animations:= $Pivot/AnimatedSprite2D



var target: Node2D
var reloading: bool = false
var health: int
var in_pain: bool = false


func _ready() -> void:
	detection_area.body_entered.connect(_on_detection_area_entered)
	detection_area.body_exited.connect(_on_detection_area_exited)
	reload_timer.timeout.connect(_on_reload_timeout)
	health = max_health
	healthbar.init_health(max_health)
	enemy_animations.play("default")
	enemy_animations.stop()


func _physics_process(delta: float) -> void:
	var can_shoot
	if target:
		can_shoot = rotate_to_target()
		
	if enemy_animations.is_playing() and enemy_animations.animation == "hurt":
		in_pain = false

		
	if in_pain:
		can_shoot = false
		
	
	if can_shoot:
		shoot()
	pass

func take_damage(damage: float) -> void:
	enemy_animations.stop()
	enemy_animations.play("hurt")
	in_pain = true
	
	

func _on_detection_area_entered(body: Node2D) -> void:
	print("Acquired Target")
	target = body


func _on_reload_timeout() -> void:
	reloading = false


func _on_detection_area_exited(_body: Node2D) -> void:
	print("Lost Target")
	target = null


func rotate_to_target() -> bool:
	var angle_to_target = get_angle_to(target.global_position)
	var lerp_result = lerp_angle(pivot.rotation, angle_to_target, turn_speed)
	var rotation_delta = abs(pivot.rotation - lerp_result)
	pivot.rotation = lerp_result
	if rotation_delta < trigger_happiness:
		return true
	else:
		return false


func shoot():
	if reloading:
		pass
	else:
		enemy_animations.play("shoot")
		var bullet = bullet_scene.instantiate()
		bullet.global_position = muzzle.global_position
		bullet.rotation = pivot.rotation
		get_tree().root.add_child(bullet)
		bullet.linear_velocity = Vector2.RIGHT.rotated(pivot.rotation) * bullet_speed
		reload_timer.start(reload_time)
		reloading = true




func _set_health(value: int) -> void:
	healthbar.health = health
	


func _on_hurtbox_body_entered(body: Node2D) -> void:
	print("ouch")
	health -= 20
	_set_health(health)
