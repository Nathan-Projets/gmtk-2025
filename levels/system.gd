class_name GameSystem extends Node

const IN_GAME = preload("res://assets/musics/in_game.mp3")
const SFX_SAND_STORM = preload("res://assets/sounds/Environment/sfxSandStorm.wav")

@export var purse: int = 0
@export var train: Train = null

@onready var world_environment: WorldEnvironment = $"../WorldEnvironment"
@onready var sandstorm_player: AudioStreamPlayer = $"../SoundPlayers/Sandstorm"
@onready var in_game_player: AudioStreamPlayer = $"../SoundPlayers/InGame"
@onready var delivery_done_player: AudioStreamPlayer = $"../SoundPlayers/DeliveryDone"

var is_sand_storm: bool = false
var cities_visible: int = 0

func _ready() -> void:
	Messenger.delivery_done.connect(_on_delivery_reached)
	Messenger.sandstorm.connect(_on_sandstorm)
	Messenger.buy_speed.connect(_on_buy_speed)
	Messenger.buy_defense.connect(_on_buy_defense)
	
	play_ingame_theme()

func _on_buy_speed():
	var cost: int = floori((train.number_speeds + 1) * 10.0)
	if (purse - cost) >= 0.0:
		purse -= cost
		train.stats["SPEED"] += 10.0
		train.number_speeds += 1
		Messenger.bought_speed.emit(train.stats["SPEED"])

func _on_buy_defense():
	var cost: int = floori((train.number_defenses + 1) * 10.0)
	if (purse - cost) >= 0.0:
		purse -= cost
		train.stats["DEFENSE"] += 10.0
		train.number_defenses += 1
		Messenger.bought_defense.emit(train.stats["DEFENSE"])

func play_ingame_theme():
	in_game_player.stream = IN_GAME
	in_game_player.playing = true

func _process(_delta: float) -> void:
	if is_sand_storm:
		world_environment.environment.fog_density = lerpf(world_environment.environment.fog_density, 0.003, 0.01)
	else:
		if world_environment.environment.fog_density > 0.0:
			world_environment.environment.fog_density = lerpf(world_environment.environment.fog_density, 0.0, 0.01)
			if world_environment.environment.fog_density < 0.0:
				world_environment.environment.fog_density = 0.0
				world_environment.environment.fog_enabled = false
		
		if sandstorm_player.playing:
			sandstorm_player.volume_linear = lerpf(db_to_linear(sandstorm_player.volume_db), 0.0, 0.02)
			if sandstorm_player.volume_linear <= 0.0:
				sandstorm_player.playing = false
				sandstorm_player.stream = null

func _on_sandstorm(start_or_stop):
	is_sand_storm = start_or_stop
	world_environment.environment.fog_enabled = start_or_stop
	if start_or_stop:
		sandstorm_player.stream = SFX_SAND_STORM
		sandstorm_player.playing = start_or_stop

func _on_delivery_reached(reward):
	purse += reward
	delivery_done_player.playing = true
