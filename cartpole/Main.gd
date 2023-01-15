extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	$CartPole.define_spaces($Env)
	$Env.register_scene($CartPole)
	$Env.setup()
