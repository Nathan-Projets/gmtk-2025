class_name DeliverySpot extends Node3D

@export var reward = 10.0
@export var time_target_ms = 3400.0
@export var camera_anchor: AnchorCamera = null

@onready var area = $Area3D
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

var should_stop: bool = false

func _process(_delta: float) -> void:
	if camera_anchor:
		var viewport = get_viewport()
		var screen_pos = camera_anchor.camera_3d.unproject_position(global_position)
		var screen_size = viewport.get_visible_rect().size
		var is_visible_screen = screen_pos.x >= 0 and screen_pos.x <= screen_size.x and screen_pos.y >= 0 and screen_pos.y <= screen_size.y
		if is_visible_screen and camera_anchor.close_enough(0.8):
			if audio_stream_player.playing != true:
				should_stop = false
				audio_stream_player.playing = true
		
		elif audio_stream_player.playing:
			should_stop = true
	
	# stop progressively
	if should_stop and audio_stream_player.playing:
		audio_stream_player.volume_linear = lerpf(db_to_linear(audio_stream_player.volume_db), 0.0, 0.02)
		if audio_stream_player.volume_linear <= 0.1:
			audio_stream_player.playing = false
			audio_stream_player.volume_db = -6.0

func _on_area_3d_body_entered(body: Area3D) -> void:
	if body.owner is Train:
		body.owner.deliver(reward, time_target_ms)
