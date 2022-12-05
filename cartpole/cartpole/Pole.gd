extends Node2D


func set_length(val):
	var factor = val / 100.0
	var offset = factor * 0.5
	
	$Arm.position.y = -val * 0.5 + 5
	$Arm.scale.y = factor
