class_name Train extends Node3D

@export var current_track: Path3D = null
var track_follow: PathFollow3D = null

enum Stats {
	SPEED, 
	TORQUE
}

@export var stats = {
	"SPEED": 20.0,
	"TORQUE": 10.0,
}

func _ready() -> void:
	track_follow = current_track.get_child(0)
	global_transform = track_follow.global_transform

func _process(delta: float) -> void:
	if track_follow != null:
		var key_string = Stats.keys()[Stats.SPEED]
		track_follow.progress += stats[key_string] * delta
		global_transform = track_follow.global_transform

func get_stat(name: Stats) -> Variant:
	var key_string = Stats.keys()[name]
	return stats.get(key_string)

func change_track(track: Path3D) -> void:
	current_track = track
	var path_local_space = global_position - current_track.global_position
	var closest_offset = current_track.curve.get_closest_offset(path_local_space)
	
	# for now there is only a PathFollow3D in the current_track,
	# so no need to search for it but careful in the future
	track_follow = current_track.get_child(0)
	track_follow.progress = closest_offset
	global_transform = track_follow.global_transform

func _on_area_3d_area_entered(area: Area3D) -> void:
	if area is not Switch:
		return
	var switch: Switch = area
	var stat = get_stat(switch.get_source())
	if stat != null and switch.evaluate(stat):
		change_track(switch.turnout)
	
