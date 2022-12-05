extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
	# The definition of the actions that can be taken by the agent
	var act = {
		# Fixed directional force to apply
		# 0 => Accelerate left
		# 1 => Don't accelerate
		# 2 => Accelerate right
		"accelerate": {
			"type": "int",
			"range": [0,2], # Inclusive range
			"dims": [1,1,1,1]
		}
	}
	
	# The definition of the observations that will be sent to the agent
	var obs = {
		"position": {
			"type": "real",
			"range": [-INF, INF],
			"dims": [1,1,1,1]
		},
		"velocity": {
			"type": "real",
			"range": [-INF, INF],
			"dims": [1,1,1,1]
		}
	}
	
	$Env.define_action_space(act)
	$Env.define_observation_space(obs)
	
	print("Actions:")
	$Env.print_action_space_def()
	
	print("\nObservations:")
	$Env.print_observation_space_def()
	
	$Env.register_scene("res://mountain_car/MountainCar.tscn")
