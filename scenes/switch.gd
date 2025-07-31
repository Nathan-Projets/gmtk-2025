class_name Switch extends Area3D

const Train = preload("res://scenes/train.gd")

@export var source: Train.Stats = Train.Stats.SPEED
@export var comparator: Comparator = Comparator.EQUAL
@export var target_value: Variant = 0.0
@export var turnout: Path3D = null
@export var no_comparison: bool = false

enum Comparator {
	EQUAL,
	NOT_EQUAL,
	GREATER,
	GREATER_EQUAL,
	LESS,
	LESS_EQUAL
}

func evaluate(stat: Variant) -> bool:
	match comparator:
		Comparator.EQUAL:
			return stat == target_value
		Comparator.NOT_EQUAL:
			return stat != target_value
		Comparator.GREATER:
			return stat > target_value
		Comparator.GREATER_EQUAL:
			return stat >= target_value
		Comparator.LESS:
			return stat < target_value
		Comparator.LESS_EQUAL:
			return stat <= target_value
		_:
			return false

func get_source() -> Train.Stats:
	return source
