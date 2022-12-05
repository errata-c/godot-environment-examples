extends Control

class_name GameBase

var step_count
var episode

var prev_score = 0
var score = 0
var dead = false
var pipes = []
var active_pipes = []
var inactive_pipes = []
var relative_speed: float = 120.0
var absolute_speed: float

var view_size: Vector2
var pipe_width: float
var bird_width: float
var pipe_start: float

var rng: RandomNumberGenerator
var reset_pos = Vector2(0.1, 0.5)
var elapsed_time

# Called when the node enters the scene tree for the first time.
func _ready():
	rng = RandomNumberGenerator.new()
	rng.randomize()
	
	step_count = 0
	episode = 0
	
	$GameOver.visible = false
	
	var viewport = get_viewport()
	viewport.connect("size_changed", self, "_on_Viewport_size_changed")
	
	$Node2D/Bird.connect("crashed", self, "lost")
	
	var pipe_scene = load("res://nodes/pipe/Pipe.tscn")
	
	# Create 20 pipes
	for _i in range(10):
		var pipe = pipe_scene.instance()
		
		$Node2D.add_child(pipe)
		pipes.append(pipe)
	pipe_width = pipes.back().get_width()
	bird_width = $Node2D/Bird.get_width()
	
	for pipe in pipes:
		pipe.pause()
		inactive_pipes.append(pipe)
		pipe.position.x = -pipe.get_width() * 2
	
	update_viewport()
	get_tree().set_group("obstacles", "speed", relative_speed)

func _physics_process(delta):
	if dead:
		if Input.is_action_just_pressed("ui_up"):
			reset(null)
	else:
		$Node2D/ParallaxBackground.scroll_offset += Vector2(-relative_speed * delta, 0)
		$Node2D/ParallaxBackground2.scroll_offset += Vector2(-relative_speed * delta, 0)
		step(null)
		
		if Input.is_action_just_pressed("ui_up"):
			$Node2D/Bird.jump()

		var screen = get_viewport_rect()
		screen = screen.grow(128)
		
		# Some quick code to prevent people from just flying over
		if !screen.has_point($Node2D/Bird.global_position):
			lost()

func update_viewport():
	var vrect = get_viewport_rect()
	var size = vrect.size
	
	var pixel_ratio = 1.0 / size.y
	
	$Node2D.scale = (3.0 * pixel_ratio) * Vector2(size.y, size.y)
	
	view_size = size / $Node2D.scale
	absolute_speed = relative_speed * view_size.y
	

func _on_Viewport_size_changed():
	update_viewport()

func compute_observation(Env):
	var velocity = $Node2D/Bird.velocity / 8.0
	var height = 1.0 - $Node2D/Bird.global_position.y / get_viewport_rect().size.y
	
	# Get all the pipes in the scene currently
	# map them to a 2d grid of values
	pass

# Interface method, called by the EnvironmentNode
func step(Env):
	# Check if any active spikes have left the view rect
	if active_pipes.size() > 0:
		var pipe = active_pipes.front()
		if not pipe.is_on_screen() and pipe.global_position.x < 0:
			pipe.pause()
			inactive_pipes.append(active_pipes.pop_front())
			score += 1
	
	# Check to see if there is a big enough gap for another pipe
	
	
	# Make sure we always generate a pipe when there are none
	var gen = active_pipes.size() == 0
	
	# If we have less than 6 pipes ready to go, create more.
	if active_pipes.size() > 0 and active_pipes.size() < 6:
		if active_pipes.back().position.x < (view_size.x-64):
			gen = rng.randi_range(0, 30) == 0
		elif active_pipes.back().position.x < (view_size.x-150):
			gen = true
	
	# We put a cap on how many can be in the scene at once
	if gen:
		# Randomly generate a height for the pipe
		# and a gap for the pipe
		# both within some reasonable range
		
		# Normalized gap size, have to determine
		# smallest possible gap first
		var gap = rng.randf_range(3.3, 5.5) * 12
		var height = rng.randf_range(8 + gap, view_size.y - gap - 32)
		
		var pipe = inactive_pipes.pop_back()
		pipe.set_gap(gap)
		pipe.position.y = height
		pipe.position.x = view_size.x + 14
		
		active_pipes.append(pipe)
		pipe.unpause()
	
	#compute_observation(Env)
	prev_score = score

func lost():
	$Node2D/Bird.pause()
	get_tree().call_group("obstacles", "pause")
	$GameOver.visible = true
	dead = true

# Interface method, called by the EnvironmentNode
func reset(Env):
	step_count = 0
	episode += 1
	
	active_pipes.clear()
	inactive_pipes.clear()
	inactive_pipes.append_array(pipes)
	
	get_tree().call_group("obstacles", "pause")
	
	for pipe in pipes:
		pipe.position.x = -16
	
	$GameOver.visible = false
	dead = false
	
	$Node2D/Bird.reset()
	$Node2D/Bird.global_position = reset_pos * get_viewport_rect().size
	$Node2D/Bird.unpause()
	
	#compute_observation(Env)
