extends Node2D

var node

# Called when the node enters the scene tree for the first time.
func _ready():
	$Env.human_control = true
	
	node = $CartPole
	node.step_delta = 0.005
	node.position = get_viewport_rect().size * 0.5
	node.scale = Vector2(2.0, 2.0)
	node.define_spaces($Env)
	node.reset($Env)

func _process(_delta):
	node.step($Env)
	$RewardLabel.text = "reward: %.2f" % $Env.reward
	$DoneLabel.text = "done: {0}".format([$Env.done])

var leftHeld = false
var rightHeld = false
func _input(event):
	if event.is_action_pressed("ui_left"):
		leftHeld = true
	elif event.is_action_pressed("ui_right"):
		rightHeld = true
	
	if event.is_action_released("ui_left"):
		leftHeld = false
	elif event.is_action_released("ui_right"):
		rightHeld = false
	
	var force = 0
	if leftHeld:
		force += -1
	if rightHeld:
		force += 1
	
	$Env.action_space["force"].set_flat(0, force + 1)
