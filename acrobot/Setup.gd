extends Node

# Called when the node enters the scene tree for the first time.
func _ready():	
	# The definition of the actions that can be taken by the agent
	var act = {
		# Fixed directional force to apply, 0 for left, 1 for right
		"action": {
			"type": "int",
			"range": [-1,1],
			"dims": [1,1,1,1]
		}
	}
	
	# The definition of the observations that will be sent to the agent
	var obs = {
		"state": {
			"type": "real",
			"range": [-4.8, 4.8],
			"dims": [6,1,1,1]
		}
	}
	
	$Env.define_action_space(act)
	$Env.define_observation_space(obs)
	
	print("Actions:")
	$Env.print_action_space_def()
	
	print("\nObservations:")
	$Env.print_observation_space_def()
	
	$Env.register_scene("res://acrobot/Acrobot.tscn")
