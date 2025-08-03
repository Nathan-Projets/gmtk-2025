extends Node3D

@onready var camera_3d: Camera3D = $Camera3D

var dragging: bool = false
var turning: bool = false
var dragging_speed: float = 0.75
var turning_speed: float = 0.01
var screen_ratio: float = 0.0
var right_vector: Vector3 = Vector3.ZERO
var forward_vector: Vector3 = Vector3.ZERO
var speed_zoom: float = 10.5
var min_zoom: float = 109.735
var max_zoom: float = 466.735

func _ready() -> void:
	var screen_size = get_viewport().get_visible_rect().size
	screen_ratio = screen_size.y / screen_size.x
	get_move_vectors()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP or event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			if dragging:
				return
			
			var direction_zoom = (-1.0 if event.button_index == MOUSE_BUTTON_WHEEL_UP else 1.0)
			var zoom_size = camera_3d.size + speed_zoom * direction_zoom
			camera_3d.size = clampf(zoom_size, min_zoom, max_zoom)
		else: 
			dragging = event.is_pressed() and event.button_index == MOUSE_BUTTON_MIDDLE
			turning = event.is_pressed() and event.button_index == MOUSE_BUTTON_RIGHT
			if event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
				check_presence_object(event)
	elif event is InputEventMouseMotion:
		if dragging:
			var zoom_scale = camera_3d.size / max_zoom  # or base it on a reference size
			var adjusted_speed = dragging_speed * zoom_scale
			global_position += right_vector * -event.relative.x * adjusted_speed
			global_position += forward_vector * -event.relative.y * adjusted_speed / screen_ratio
		if turning:
			rotate_y(-event.relative.x * 0.5 * turning_speed)
			get_move_vectors()

func check_presence_object(event):
	var click_pos = event.position
	var from = camera_3d.project_ray_origin(click_pos)
	var to = from + camera_3d.project_ray_normal(click_pos) * 5000.0
	var params: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(from, to)
	var result = get_world_3d().direct_space_state.intersect_ray(params)
	if result and result.collider is Train:
		var train: Train = result.collider
		train.apply_boost()

func get_move_vectors():
	# Get right and forward vectors from the camera's basis
	right_vector = camera_3d.global_transform.basis.x
	forward_vector = camera_3d.global_transform.basis.z

	# Flatten to XZ plane
	right_vector.y = 0
	forward_vector.y = 0

	# Normalize to prevent speed issues
	right_vector = right_vector.normalized()
	forward_vector = forward_vector.normalized()
