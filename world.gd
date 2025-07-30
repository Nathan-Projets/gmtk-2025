extends Node3D

#@onready var train_track = $TrackManager/Track/PathFollow3D
#@onready var train = $TrackManager/Track/PathFollow3D/Train
@onready var checkpoints = [$DeliverySpot]

#@export var train_speed = 0.5

var purse = 0.0

func _ready() -> void:
	for checkpoint in checkpoints:
		checkpoint.delivery_reached.connect(_on_delivery_reached)

#func _process(delta: float) -> void:
	#train_track.progress += delta * train_speed

func _on_delivery_reached(amount):
	purse += amount
	print("amount is ", purse)
