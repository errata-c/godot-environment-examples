extends Node2D

var screen_pos: int = 0
var screen_width: int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	var vrect = get_viewport_rect()
	var size = vrect.size
	
	screen_width = size.x;
	screen_pos = vrect.position.x
	
	$Pipe.speed = 0.4 * size.x
	$Pipe.stopped = false
	$Pipe.gap = 40.0


func _process(delta):
	var elapsed = OS.get_ticks_msec() / 1000.0
	var gap = (cos(elapsed) + 1.5) * 60.0
	
	$Pipe.gap = gap
	
	if not $Pipe.is_on_screen():
		$Pipe.global_position.x = screen_pos + screen_width + 40
