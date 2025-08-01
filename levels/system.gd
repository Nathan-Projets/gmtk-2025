class_name GameSystem extends Node

@export var purse: int = 0

func _ready() -> void:
	Messenger.delivery_done.connect(_on_delivery_reached)

func _on_delivery_reached(reward):
	purse += reward
