class_name Train extends Node3D

const SFX_TRAIN = preload("res://assets/sounds/Train/Train/sfxTrain.wav")
const SFX_TRAIN_FAST = preload("res://assets/sounds/Train/Train/sfxTrainFast.wav")

@export var camera_anchor: AnchorCamera = null

@export var speed_boost: float = 3.0
@export var speed_boost_cost: float = 25.0
@export var cooling_factor: float = 1.5
@export var overheat_speed_factor: float = 2.0
@export var temperature_max: int = 100
@export var current_track: Path3D = null

#@onready var last_delivery_time: int = Time.get_ticks_msec()
@onready var cargo_integrity: float = 100.0
@onready var cargo_condition: float = 100.0

@onready var time_score = 1.0
@onready var decision_score = 1.0
@onready var condition_score = 1.0

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var over_heat_player: AudioStreamPlayer = $OverHeatPlayer

var should_apply_penalty: bool = false
var temperature: float = 0
var speed_boost_value: float = 1.0
var track_follow: PathFollow3D = null
var mouse_over: bool = false
var should_stop: bool = false

enum Stats {
	SPEED, 
	WEIGHT,
	DEFENSE,
}

@export var stats = {
	"SPEED": 200.0,
	"WEIGHT": 1000.0,
	"DEFENSE": 100.0,
}

var number_speeds: int = 0
var number_defenses: int = 0

var init: bool = false

func _ready() -> void:
	
	for child in current_track.get_children():
		if child is PathFollow3D:
			track_follow = child
			break
	
	global_transform = track_follow.global_transform
	call_deferred("init_stats_ui")

func _process(delta: float) -> void:
	if not init:
		Messenger.temperature_changed.emit(temperature / temperature_max)
	
	if speed_boost_value >= 1.05:
		speed_boost_value = lerpf(speed_boost_value, 1.0, delta)
		if speed_boost_value <= 1.05:
			speed_boost_value = 1.0
	
	if temperature > 0.0:
		temperature -= cooling_factor * delta
		if temperature < 0.0:
			temperature = 0.0
		Messenger.temperature_changed.emit(temperature / temperature_max)
	
	if track_follow != null:
		var key_string = Stats.keys()[Stats.SPEED]
		var speed = stats[key_string] * speed_boost_value
		if is_over_heat():
			speed /= overheat_speed_factor
		track_follow.progress += speed * delta
		global_transform = track_follow.global_transform
	
	if camera_anchor:
		var viewport = get_viewport()
		var screen_pos = camera_anchor.camera_3d.unproject_position(global_position)
		var screen_size = viewport.get_visible_rect().size
		var is_visible_screen = screen_pos.x >= 0 and screen_pos.x <= screen_size.x and screen_pos.y >= 0 and screen_pos.y <= screen_size.y
		if is_visible_screen and camera_anchor.close_enough(0.95):
			if audio_stream_player.playing != true:
				should_stop = false
				audio_stream_player.playing = true
			if is_over_heat() and over_heat_player.playing != true:
				over_heat_player.playing = true
		
		elif audio_stream_player.playing:
			should_stop = true
	
	# stop progressively
	if should_stop and audio_stream_player.playing:
		audio_stream_player.volume_linear = lerpf(db_to_linear(audio_stream_player.volume_db), 0.0, 0.007)
		if audio_stream_player.volume_linear <= 0.1:
			audio_stream_player.playing = false
			audio_stream_player.volume_db = -10.0

func init_stats_ui():
	Messenger.bought_speed.emit(stats["SPEED"])
	Messenger.bought_defense.emit(stats["DEFENSE"])

func get_stat(id: Stats) -> Variant:
	var key_string = Stats.keys()[id]
	return stats.get(key_string)

func is_over_heat():
	return temperature > temperature_max

func apply_boost():
	if temperature < temperature_max:
		speed_boost_value = speed_boost
		temperature += speed_boost_cost
		Messenger.temperature_changed.emit(temperature / temperature_max)

func apply_damage(defense_needed, percentage):
	# check the defense to mitigate the damage
	if get_stat(Stats.DEFENSE) >= defense_needed:
		percentage = 0.0
		
	cargo_condition -= cargo_condition * percentage

func change_track(track: Path3D) -> void:
	current_track = track
	
	var path_local_space = current_track.to_local(global_position)
	var closest_offset = current_track.curve.get_closest_offset(path_local_space)
	
	track_follow = (current_track as Track).get_path_follow()
	track_follow.progress = closest_offset
	global_transform = track_follow.global_transform

func _on_area_3d_area_entered(area: Area3D) -> void:
	if area is not Switch:
		return
	var switch: Switch = area
	var stat = get_stat(switch.get_source())
	if stat != null:
		should_apply_penalty = switch.evaluate(stat)
		if should_apply_penalty:
			decision_score -= decision_score * 0.1
		
		var next_track = switch.get_next_track()
		if next_track != current_track:
			change_track(next_track)

func deliver(reward, _time_target):
	# no time to calculate the time between deliveries so unfortunately I disable this
	time_score = 1.0
	# var now = Time.get_ticks_msec()
	#var time_spent_to_deliver = now - last_delivery_time
	#if time_spent_to_deliver <= time_target:
		#time_score = 1.0
	#else:
		#time_score =  max(0, 1.0 - ((time_spent_to_deliver - time_target) / time_target))

	condition_score = cargo_condition / cargo_integrity
	
	var random_score = randf_range(0.0, 0.7)
	var quality_score = (time_score + condition_score + decision_score) / 3 + random_score
	var money = floori(reward * quality_score)
	
	#last_delivery_time = now
	Messenger.delivery_done.emit(money)
