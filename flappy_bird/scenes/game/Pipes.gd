extends Node2D

var pipes = []
var active_pipes = []
var inactive_pipes = []

var hgap: float
var vgap: float
var pipe_width: float
export var view_size: Vector2 = Vector2(800, 600)

var rng: RandomNumberGenerator

# Called when the node enters the scene tree for the first time.
func _ready():
	rng = RandomNumberGenerator.new()
	rng.randomize()
	
	var pipe_scene = load("res://nodes/pipe/Pipe.tscn")
	
	# Create 10 pipes
	for _i in range(10):
		var pipe = pipe_scene.instance()
		
		add_child(pipe)
		pipes.append(pipe)
	pipe_width = pipes.back().get_width()
	
	for pipe in pipes:
		pipe.pause()
		inactive_pipes.append(pipe)
		pipe.position.x = -pipe.get_width() * 2
	
	gen_gaps()

func gen_gaps():
	hgap = rng.randf_range(pipe_width * 2.5, pipe_width * 6.0)
	vgap = rng.randf_range(pipe_width * 3.0, pipe_width * 6.0)

func pipe_start():
	return view_size.x - pipe_width

func step():
	var passed = 0
	
	# Check if any active spikes have left the view rect
	if active_pipes.size() > 0:
		var pipe = active_pipes.front()
		if not pipe.is_on_screen() and pipe.global_position.x < 0:
			pipe.pause()
			inactive_pipes.append(active_pipes.pop_front())
			passed += 1
	
	# Make sure we always generate a pipe when there are none
	var gen = active_pipes.size() == 0
	
	if not gen:
		# Check to see if there is a big enough gap for another pipe
		gen = (active_pipes.back().position.x - pipe_start()) > hgap
	
	# We put a cap on how many can be in the scene at once
	if gen:
		# Randomly generate a height for the pipe
		# and a gap for the pipe
		# both within some reasonable range
		
		var height = rng.randf_range(8 + vgap, view_size.y - vgap - 32)
		
		var pipe = inactive_pipes.pop_back()
		pipe.set_gap(vgap)
		pipe.position.y = height
		pipe.position.x = view_size.x + 14
		
		active_pipes.append(pipe)
		pipe.unpause()
		
		gen_gaps()
	
	return passed
