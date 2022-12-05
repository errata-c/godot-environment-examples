extends Node2D
class_name Obstacle

export var speed: float = 1.0
export var paused: bool setget set_paused, get_paused

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("obstacles")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	position.x -= speed * delta

func pause():
	set_paused(true)

func unpause():
	set_paused(false)
	
func set_paused(val):
	set_physics_process(not val)
	
func get_paused():
	return not is_physics_processing()

func is_on_screen():
	return $VisibilityNotifier2D.is_on_screen()
