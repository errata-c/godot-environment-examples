extends Node2D

var episode = -1
var step_count = 0

var angle = 0.0
var angular_velocity = 0.0
var x_position = 0.0
var velocity = 0.0

var mass_cart = 1.0
var mass_pole = 0.1
var total_mass = mass_cart + mass_pole
var half_length = 0.5
var half_mass_pole = mass_pole * half_length

export var force_mag = 10.0
export var step_delta = 0.02
var gravity = -9.8

var position_threshold = 2.4
var angle_threshold = deg2rad(12.0)

var steps_beyond_terminate = -1

func define_spaces(Env):
	# The definition of the actions that can be taken by the agent
	var act = {
		# Fixed directional force to apply, 0 for left, 1 for right
		"force": {
			"type": "i8",
			"range": [0,1],
			"dims": [1,1,1,1]
		}
	}
	
	# The definition of the observations that will be sent to the agent
	var obs = {
		"position": {
			"type": "f64",
			"range": [-4.8, 4.8],
			"dims": [1,1,1,1]
		},
		"velocity": {
			"type": "f64",
			"range": [-INF, INF],
			"dims": [1,1,1,1]
		},
		"pole_angle": {
			"type": "f64",
			"range": [-deg2rad(28.0), deg2rad(28.0)],
			"dims": [1,1,1,1]
		},
		"pole_angular_velocity": {
			"type": "f64",
			"range": [-INF, INF],
			"dims": [1,1,1,1]
		}
	}
	
	Env.define_action_space(act)
	Env.define_observation_space(obs)

func _ready():
	var rect = get_viewport_rect()
	var size = rect.size
	position = size * 0.5

# Method to compute the observation for the scene, not a part of the interface
func compute_observation(Env):
	var obs = Env.observation_space
	
	obs.position.set_flat(0, x_position)
	obs.velocity.set_flat(0, velocity)
	obs.pole_angle.set_flat(0, angle)
	obs.pole_angular_velocity.set_flat(0, angular_velocity)
	
	var terminated = x_position < -position_threshold or x_position > position_threshold or angle < -angle_threshold or angle > angle_threshold
	
	if not terminated:
		Env.reward = 1.0
	elif steps_beyond_terminate == -1:
		steps_beyond_terminate += 1
		Env.reward = 1.0
	else:
		Env.reward = 0.0
		steps_beyond_terminate += 1
	
	Env.done = terminated

# Interface method, called by the EnvironmentNode
func step(Env):
	var action = Env.action_space.force.get_flat(0)
	
	var force = (action - 1) * force_mag
	
	var costheta = cos(angle)
	var sintheta = sin(angle)
	
	var tmp = (force + half_mass_pole * angular_velocity * angular_velocity * sintheta) / total_mass
	var angular_acceleration = (gravity * sintheta - costheta * tmp) / (half_length * ((4.0 / 3.0) - mass_pole * costheta * costheta / total_mass))
	
	var acceleration = tmp - half_mass_pole * angular_acceleration * costheta / total_mass
	
	# Update the state
	x_position = x_position + step_delta * velocity
	velocity = velocity + step_delta * acceleration
	
	angle = angle + step_delta * angular_velocity
	angular_velocity = angular_velocity + step_delta * angular_acceleration
	
	update_nodes()
	
	step_count += 1
	
	compute_observation(Env)

# Interface method, called by the EnvironmentNode
func reset(Env):
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	step_count = 0
	episode += 1
	
	var low = -0.05
	var high = 0.05
	
	angular_velocity = rng.randf_range(low, high)
	angle = rng.randf_range(low, high)
	x_position = rng.randf_range(low, high)
	velocity = rng.randf_range(low, high)
	
	update_nodes()
	
	compute_observation(Env)


func update_nodes():
	var rect = get_viewport_rect()
	var size = rect.size
	var center = size * 0.5

	var sfactor = size.x / (position_threshold * 2.0)
	var pole_len = sfactor * half_length * 2.0
	
	$Floor.scale.x = size.x / 100.0
	
	$Cart/Pole.set_length(pole_len)
	$Cart/Pole.rotation = angle
	$Cart.position = Vector2(x_position, 0)
