class_name Switch extends Area3D

@export var condition = null
@export var turnout: Path3D = null

var used = false

func _on_train_entered(area: Area3D) -> void:
	if used:
		return
		
	var train = area.owner
	if train is not Train or turnout == null:
		return
	
	if condition == null:
		train.changeTrack(turnout)
	else:
		print("should check the switch on train")
		
	used = true


func _on_area_exited(area: Area3D) -> void:
	if not used:
		return
		
	used = false
