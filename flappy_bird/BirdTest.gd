extends Node2D

var prev_score = 0
var score = 0
var dead = false
var pipes = []
var active_pipes = []
var inactive_pipes = []
var relative_speed = 0.4

var reset_pos
var rng: RandomNumberGenerator

# Called when the node enters the scene tree for the first time.
func _ready():
	rng = RandomNumberGenerator.new()
	rng.randomize()
	reset_pos = $Bird.global_position
	
	# Create the plane
	# Create some spikes
	# The spikes will begin moving towards the player
	# Continually make more spikes, randomly altering their heights
	
	# The observation will be the height of the plane
	# the velocity of the plane
	
	# The only action will be tap, 
	# which causes the plane to bounce upward.
	var pipe_scene = load("res://nodes/pipe/Pipe.tscn")
	
	var viewport = get_viewport()
	viewport.connect("size_changed", self, "_on_Viewport_size_changed")
	
	# Create 20 pipes
	for i in range(20):
		pipes.append(pipe_scene.instance())
	
	for pipe in pipes:
		pipe.stop()
		inactive_pipes.append(pipe)

	update_viewport()

func compute_observation(Env):
	var vrect = get_viewport_rect()
	var size = vrect.size
	
	Env.set_observation("height", $Bird.position.y / size.y)
	Env.set_observation("velocity", $Bird.velocity)
	
	# Parse the list of active spikes, put their positions
	# into a simple array of quantized values, like a scanline
	# This will make the environment more challenging
	# as the agent will have to learn to understand the 
	# scanline, instead of discrete positions.
	#Env.set_observation("")
	
	Env.reward = score
	Env.done = !dead
	
func step(Env):
	# Check if any active spikes have left the view rect
	var left = []
	var stayed = []
	for pipe in active_pipes:
		if not pipe.is_on_screen():
			pipe.stop()
			left.append(pipe)
		else:
			stayed.append(pipe)
	
	active_pipes = stayed
	inactive_pipes.append_array(left)
	
	# Check if we have passed a spike
	for pipe in active_pipes:
		if pipe.global_position.x < $Bird.global_position.x:
			score += 1
			break
	
	# We put a cap on how many can be in the scene at once
	if (active_pipes.size() < 6 and 
		rng.randi_range(0, 15) == 0): # 1 in 16 chance?
		# Randomly generate a height for the pipe
		# and a gap for the pipe
		# both within some reasonable range
		
		# Normalized gap size, have to determine
		# smallest possible gap first
		var gap = rng.randf_range(0.2, 0.4)
		var height = rng.randf_range(0.01 + gap, 0.99 - gap)
		
		var pipe = inactive_pipes.pop_back()
		pipe.set_gap(gap)
		
		pipe.position.y = height
		pass
	
	#compute_observation(Env)
	prev_score = score

func reset(Env):
	score = 0
	prev_score = 0
	
	# put the plane back in its original position
	# set its velocity back to zero
	$Bird.global_position = reset_pos
	$Bird.reset()
	
	#compute_observation(Env)

func _process(delta):
	if Input.is_action_just_pressed("ui_up"):
		$Bird.jump()
	
	step(null)

func update_viewport():
	var vrect = get_viewport_rect()
	var size = vrect.size
	
	for pipe in pipes:
		pipe.set_speed(relative_speed * size.x)

func _on_Plane_crash():
	dead = true
	
func _on_Viewport_size_changed():
	update_viewport()
