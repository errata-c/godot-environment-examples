extends Obstacle

export var gap: float = 10.0 setget set_gap, get_gap


func set_gap(val):
	var half = val * 0.5
	$Top.position.y = -half
	$Bot.position.y = half

func get_gap():
	return abs($Top.position.y - $Bot.position.y)

func get_width():
	return 24
