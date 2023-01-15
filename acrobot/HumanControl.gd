extends Node2D

var node

# Called when the node enters the scene tree for the first time.
func _ready():
	$Env.human_control = true
	
	node = $Acrobot
	
	node.define_spaces($Env)
	node.position = get_viewport_rect().size * Vector2(0.5, 0.25)
	node.reset($Env)

func _process(_delta):
	var step = node.step($Env)
	$RewardLabel.text = "reward: %.2f" % $Env.reward
	$DoneLabel.text = "done: {0}".format([$Env.done])
	
	var obs = $Env.observation_space
	
	$Link1AV.text = "link 1 angular velocity: %.2f" % obs["state"].get_flat(4)
	$Link2AV.text = "link 2 angular velocity: %.2f" % obs["state"].get_flat(5)

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
		force -= 1
	elif rightHeld:
		force += 1
	
	$Env.action_space["action"] = force
