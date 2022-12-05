extends KinematicBody2D


# Declare member variables here. Examples:
export var velocity: float = 0.0
export var gravity: float setget set_gravity, get_gravity
export var jump_speed: float = 10.0
export var max_velocity: float = 32.0

var default_gravity: float = 45.0
var cgravity: float = default_gravity
var should_jump: bool = false
var alive: bool = true

signal crashed

func _ready():
	unpause()

func _physics_process(delta):
	velocity += cgravity * delta
	
	if should_jump:
		should_jump = false
		velocity = min(0.0, velocity)
		velocity += -jump_speed
	
	velocity = max(-max_velocity, min(velocity, max_velocity))
	
	rotation = atan(velocity * 0.12)
	
	var result = move_and_collide(Vector2(0.0, 60.0 * velocity * delta))
	if result != null:
		# Collision detected
		emit_signal("crashed")

func is_paused():
	return is_physics_processing()

func pause():
	$AnimationPlayer.play("default")
	set_physics_process(false)
	
func unpause():
	set_physics_process(true)
	$AnimationPlayer.play("flap")

# Interface method, used to queue up a jump
func jump():
	should_jump = true
	

func reset():
	should_jump = false
	velocity = 0.0
	alive = true
	
func set_gravity(val: float):
	default_gravity = val
	if not is_paused():
		cgravity = default_gravity

func get_gravity():
	return default_gravity

func get_width():
	return 13.2

func get_height():
	return 11.2
