class_name Train extends Node3D

@export var speed = 20.0
@export var current_track: Path3D = null
var track_follow: PathFollow3D = null

func _ready() -> void:
	track_follow = current_track.get_child(0)
	global_transform = track_follow.global_transform

func _process(delta: float) -> void:
	if track_follow != null:
		track_follow.progress += speed * delta
		global_transform = track_follow.global_transform

func changeTrack(track: Path3D) -> void:
	current_track = track
	var path_local_space = global_position - current_track.global_position
	var closest_offset = current_track.curve.get_closest_offset(path_local_space)
	
	# for now there is only a PathFollow3D in the current_track,
	# so no need to search for it but careful in the future
	track_follow = current_track.get_child(0)
	track_follow.progress = closest_offset
	global_transform = track_follow.global_transform
