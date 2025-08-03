class_name GameSystem extends Node

@export var purse: int = 0

@onready var world_environment: WorldEnvironment = $"../WorldEnvironment"

var is_sand_storm: bool = false

func _ready() -> void:
	Messenger.delivery_done.connect(_on_delivery_reached)
	Messenger.sandstorm.connect(_on_sandstorm)

func _process(delta: float) -> void:
	if is_sand_storm:
		world_environment.environment.fog_density = lerpf(world_environment.environment.fog_density, 0.003, 0.01)
	elif world_environment.environment.fog_density > 0.0:
		world_environment.environment.fog_density = lerpf(world_environment.environment.fog_density, 0.0, 0.01)
		if world_environment.environment.fog_density < 0.0:
			world_environment.environment.fog_density = 0.0
			world_environment.environment.fog_enabled = false

func _on_sandstorm(start_or_stop):
	is_sand_storm = true
	world_environment.environment.fog_enabled = start_or_stop

func _on_delivery_reached(reward):
	purse += reward
