@tool
extends RigidBody3D

@export var use_particles: bool = true

@onready var stone_large_d: MeshInstance3D = $stone_largeD
@onready var smoke_effect: SmokeEffect = $SmokeEffect
@onready var timer_to_destroy: Timer = $TimerToDestroy
@onready var never_collided: bool = true
@onready var should_destroy: bool = false

@export_group("debug")
@export var start_particles: bool = false

func _ready() -> void:
	if not use_particles:
		smoke_effect.visible = false

func _process(delta: float) -> void:
	if should_destroy == true:
		stone_large_d.scale *= 1.0 - delta * 10.0
		if stone_large_d.scale < Vector3(1.0, 1.0, 1.0):
			_on_destroy()

func _on_area_3d_body_entered(body: Node3D) -> void:
	if not use_particles and not start_particles:
		return
	if body is StaticBody3D and not should_destroy:
		on_rock_collided()

func on_rock_collided():
	_play_smoke_animation()

func _play_smoke_animation():
	if never_collided:
		timer_to_destroy.start()
		never_collided = false
		smoke_effect.emit_particles()

func _on_timer_to_destroy_timeout() -> void:
	should_destroy = true
	
func _on_destroy():
	queue_free()
