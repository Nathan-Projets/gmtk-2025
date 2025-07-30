extends Node3D

signal delivery_reached(amount)

@onready var area = $Area3D

@export var reward = 10.0

func _on_area_3d_body_entered(body: Area3D) -> void:
	# var train = body.owner
	# maybe do some checks on the stats or whatever
	delivery_reached.emit(reward)
