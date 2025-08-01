class_name DeliverySpot extends Node3D

@onready var area = $Area3D

@export var reward = 10.0
@export var time_target_ms = 3400.0

func _on_area_3d_body_entered(body: Area3D) -> void:
	if body.owner is Train:
		body.owner.deliver(reward, time_target_ms)
