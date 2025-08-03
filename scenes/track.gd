@tool
class_name Track extends Path3D

@export var distance_between_planks = 1.0:
	set(value):
		distance_between_planks = value
		is_dirty = true

@onready var path_follow_3d: PathFollow3D = $PathFollow3D

var is_dirty = false

func _ready() -> void:
	var mm_instance = $MultiMeshInstance3D
	mm_instance.multimesh = mm_instance.multimesh.duplicate()
	is_dirty = true

func _process(_delta: float) -> void:
	if is_dirty:
		_update_multimesh()
		is_dirty = false

func _update_multimesh():
	var path_length: float = curve.get_baked_length()
	var number_planks = floor(path_length / distance_between_planks)
	
	var multimesh: MultiMesh = $MultiMeshInstance3D.multimesh
	multimesh.instance_count = number_planks
	var offset = distance_between_planks / 2.0
	
	for i in range(0, number_planks):
		var curve_distance = offset + distance_between_planks * i
		var position_curve = curve.sample_baked(curve_distance, true)
		
		var basis_curve = Basis()
		var up = curve.sample_baked_up_vector(curve_distance, true)
		var forward = position_curve.direction_to(curve.sample_baked(curve_distance + 0.1, true))
		
		basis_curve.y = up
		basis_curve.x = forward.cross(up).normalized()
		basis_curve.z = -forward
		
		var transform_curve = Transform3D(basis_curve, position_curve)
		multimesh.set_instance_transform(i, transform_curve)

func _on_curve_changed() -> void:
	is_dirty = true

func get_path_follow() -> PathFollow3D:
	return path_follow_3d
