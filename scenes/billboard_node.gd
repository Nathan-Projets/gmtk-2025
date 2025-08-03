class_name BillboardNode extends StaticBody3D

const ROADS_RIGHT_SWITCH = preload("res://assets/textures/roads-right-switch.png")
const ROADS_LEFT_SWITCH = preload("res://assets/textures/roads-left-switch.png")

@export var camera: Camera3D
@export var switch: Switch
@export var angle_rotation_degrees: float= 0.0

@onready var foreground: Sprite3D = $Foreground
@onready var audio_stream_player_3d: AudioStreamPlayer3D = $AudioStreamPlayer3D

func _ready() -> void:
	if switch.go_to_turnout:
		foreground.texture = ROADS_LEFT_SWITCH
	else: 
		foreground.texture = ROADS_RIGHT_SWITCH
	
	foreground.rotate_z(deg_to_rad(angle_rotation_degrees))

func _process(_delta):
	look_at(camera.global_transform.origin, Vector3.UP)

func handle_click():
	switch.switch()
	audio_stream_player_3d.playing = true
	
	if switch.go_to_turnout:
		foreground.texture = ROADS_LEFT_SWITCH
	else: 
		foreground.texture = ROADS_RIGHT_SWITCH
