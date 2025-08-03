class_name SandStorm extends Node3D

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Train:
		Messenger.sandstorm.emit(true)

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body is Train:
		Messenger.sandstorm.emit(false)
