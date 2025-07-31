class_name Train extends Node3D

@export var current_track: Path3D = null
var track_follow: PathFollow3D = null

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
	var path_local_space = global_position - current_track.global_position
	var closest_offset = current_track.curve.get_closest_offset(path_local_space)
	
	# for now there is only a PathFollow3D in the current_track,
	# so no need to search for it but careful in the future
	for child in current_track.get_children():
		if child is PathFollow3D:
			track_follow = child
			break
	track_follow.progress = closest_offset
	global_transform = track_follow.global_transform

func _on_area_3d_area_entered(area: Area3D) -> void:
	if area is not Switch:
		return
	var switch: Switch = area
	var stat = get_stat(switch.get_source())
	if stat != null and switch.evaluate(stat):
		change_track(switch.turnout)
	
