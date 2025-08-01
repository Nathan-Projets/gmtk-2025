class_name Train extends Node3D

@export var current_track: Path3D = null
var track_follow: PathFollow3D = null

@onready var last_delivery_time: int = Time.get_ticks_msec()
@onready var cargo_integrity: float = 100.0
@onready var cargo_condition: float = 100.0

@onready var time_score = 1.0
@onready var decision_score = 1.0
@onready var condition_score = 1.0

enum Stats {
	SPEED, 
	WEIGHT,
	DEFENCE,
}

@export var stats = {
	"SPEED": 200.0,
	"WEIGHT": 1000.0,
	"DEFENCE": 100.0,
}

func _ready() -> void:
	randomize()
	
	for child in current_track.get_children():
		if child is PathFollow3D:
			track_follow = child
			break
	global_transform = track_follow.global_transform

func _process(delta: float) -> void:
	if track_follow != null:
		var key_string = Stats.keys()[Stats.SPEED]
		track_follow.progress += stats[key_string] * delta
		global_transform = track_follow.global_transform

func get_stat(id: Stats) -> Variant:
	var key_string = Stats.keys()[id]
	return stats.get(key_string)

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
	if switch.turnout == current_track:
		# already on the same track it wants me to change so no need to do anything
		return
	var stat = get_stat(switch.get_source())
	if stat != null and switch.evaluate(stat):
		change_track(switch.turnout)

func deliver(reward, time_target):
	var now = Time.get_ticks_msec()
	var time_spent_to_deliver = now - last_delivery_time
	
	if time_spent_to_deliver <= time_target:
		time_score = 1.0
	else:
		time_score =  max(0, 1.0 - ((time_spent_to_deliver - time_target) / time_target))

	condition_score = cargo_condition / cargo_integrity
	
	var random_score = randf_range(0.0, 0.3)
	var quality_score = (time_score + condition_score + decision_score) / 3 + random_score
	var money = floori(reward * quality_score)
	
	last_delivery_time = now
	Messenger.delivery_done.emit(money)
