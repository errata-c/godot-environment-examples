extends Node2D

# The Solver is using position based dynamics, modified slightly for 2D.
# See:
#   Müller, M., Macklin, M., Chentanez, N., Jeschke, S. and Kim, T.-Y. (2020), 
#   Detailed Rigid Body Simulation with Extended Position Based Dynamics. 
#   Computer Graphics Forum, 39: 101-112. https://doi.org/10.1111/cgf.14105
var solver_class = load("res://acrobot/PBD_Solver.gd")
var solver

var episode = -1
var step_count = 0

var max_vel_1 = 4 * PI
var max_vel_2 = 9 * PI

var torques = [-1.0, 0.0, 1.0]
var torque_noise_max = 0.0

var state = [0.0, 0.0, 0.0, 0.0]

var dt = 0.05

func _ready():
	solver = solver_class.new()

func define_spaces(Env):
	# The definition of the actions that can be taken by the agent
	var act = {
		# Fixed directional force to apply, -1 for left, +1 for right
		"action": {
			"type": "i8",
			"range": [-1,1],
			"dims": [1,1,1,1]
		}
	}
	
	# 6 values defining the state of the system.
	
	# 0 -> cosine of first angle
	# 1 -> sine of first angle
	# 2 -> cosine of the second angle
	# 3 -> sine of the second angle
	# 4 -> angular velocity of the first link
	# 5 -> angular velocity of the second link
	var obs = {
		"state": {
			"type": "f64",
			"range": [-4.8, 4.8],
			"dims": [6,1,1,1]
		}
	}
	
	Env.define_action_space(act)
	Env.define_observation_space(obs)

# Method to compute the observation for the scene, not a part of the interface
func compute_observation(Env):
	var a1 = solver.get_link_angle(0)
	var a2 = solver.get_link_angle(1)
	
	var obs = [
		cos(a1),
		sin(a1),
		cos(a2),
		sin(a2),
		solver.get_link_angular_velocity(0),
		solver.get_link_angular_velocity(1),
	]
	
	# If the pendulum reaches a certain height.
	if (-cos(a1) - cos(a1 + a2)) > 1.0:
		Env.done = true
		Env.reward = 0.0
	else:
		Env.done = false
		Env.reward = -1.0
	
	Env.set_observation("state", obs)
	

# Interface method, called by the EnvironmentNode
func step(Env):
	var action = Env.get_action("action")
	var torque = torques[action]
	
	if torque_noise_max > 0.0:
		torque += rand_range(-torque_noise_max, torque_noise_max)
		
	solver.set_torque(0, torque)
	
	solver.solve(dt)
	
	update_nodes()
	
	step_count += 1
	
	compute_observation(Env)

# Interface method, called by the EnvironmentNode
func reset(Env):
	randomize()
	
	step_count = 0
	episode += 1
	
	var low = -0.3
	var high = 0.3
	
	for i in range(len(state)):
		state[i] = rand_range(low, high)
	
	solver.reset(state[0], state[1], state[2], state[3])
	
	update_nodes()
	
	compute_observation(Env)


func update_nodes():
	# Update the scale of the scene to fit better
	var form1 = solver.get_link_transform(0)
	var form2 = solver.get_link_transform(1)
	
	$Links/Arm0.transform = form1
	$Links/Arm1.transform = form2
	
	$Links/Joint0.position = form1.xform(Vector2(0.0, -0.25))
	$Links/Joint1.position = form1.xform(Vector2(0.0, 0.25))
