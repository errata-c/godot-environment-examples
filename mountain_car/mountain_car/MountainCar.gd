extends Node2D

var episode = -1
var step_count = 0

var min_position = -1.2
var max_position = 0.6
var max_speed = 0.07
var goal_position = 0.5
var goal_velocity = 0.0

var car_position = 0.0
var car_velocity = 0.0

export var force_mag = 0.001
var gravity = 0.0025

var steps_beyond_terminate = -1

func _ready():
	var rect = get_viewport_rect()
	var size = rect.size
	position = size * 0.5

# Method to compute the observation for the scene, not a part of the interface
func compute_observation(Env):
	Env.set_observation("position", car_position)
	Env.set_observation("velocity", car_velocity)
	
	Env.done = car_position >= goal_position and car_velocity >= goal_velocity
	Env.reward = -1.0

# Interface method, called by the EnvironmentNode
func step(Env):
	var action = Env.get_action("accelerate")
	
	var velocity_delta = (action - 1.0) * force_mag + cos(3.0 * car_position) * -gravity
	
	car_velocity += velocity_delta
	car_velocity = clamp(car_velocity, -max_speed, max_speed)
	
	car_position += car_velocity
	car_position = clamp(car_position, min_position, max_position)
	
	# Prevent accumulation of velocity at minimum range.
	if car_position <= min_position and car_velocity < 0.0:
		car_velocity = 0.0
	
	update_nodes()
	
	step_count += 1
	
	compute_observation(Env)

# Interface method, called by the EnvironmentNode
func reset(Env):
	randomize()
	
	step_count = 0
	episode += 1
	
	var low = -0.6
	var high = -0.4
	
	car_position = rand_range(low, high)
	car_velocity = 0.0
	
	update_nodes()
	
	compute_observation(Env)


func update_nodes():
	var rect = get_viewport_rect()
	var size = rect.size
	var center = size * 0.5
	
	
