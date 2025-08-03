class_name SandStorm extends Node3D

@export_range(0.0, 1.0, 0.05) var probability: float = 0.3
@export var defense_needed: float

func should_event_fire() -> bool:
	return randf() < probability

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Train:
		if should_event_fire():
			body.apply_damage(defense_needed, 0.1) # 10% less cargo integrity
			Messenger.sandstorm.emit(true)

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body is Train:
		Messenger.sandstorm.emit(false)
