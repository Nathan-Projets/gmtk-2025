class_name Switch extends Area3D

@export_group("state")
@export var go_to_turnout: bool
@export_group("comparison")
@export var source: Train.Stats = Train.Stats.SPEED
@export var comparator: Comparator = Comparator.EQUAL
@export var target_value: float = 0.0
@export var turnout: Path3D = null
@export var base: Path3D = null
@export var no_comparison: bool = false

var should_apply_penalty: bool = false

enum Comparator {
	EQUAL,
	NOT_EQUAL,
	GREATER,
	GREATER_EQUAL,
	LESS,
	LESS_EQUAL
}

func switch():
	go_to_turnout = !go_to_turnout

func get_next_track():
	return turnout if go_to_turnout else base

# evaluate if the penalty will have to be applicated at the next delivery 
func evaluate(stat: float) -> bool:
	
	if no_comparison:
		should_apply_penalty = false
	else:
		match comparator:
			Comparator.EQUAL:
				should_apply_penalty = not(stat == target_value)
			Comparator.NOT_EQUAL:
				should_apply_penalty = not(stat != target_value)
			Comparator.GREATER:
				should_apply_penalty = not(stat > target_value)
			Comparator.GREATER_EQUAL:
				should_apply_penalty = not(stat >= target_value)
			Comparator.LESS:
				should_apply_penalty = not(stat < target_value)
			Comparator.LESS_EQUAL:
				should_apply_penalty = not(stat <= target_value)
			_:
				should_apply_penalty = false
	
	return should_apply_penalty

func get_source() -> Train.Stats:
	return source
