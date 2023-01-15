extends Node2D

func _ready():
	$Acrobot.define_spaces($Env)
	$Env.register_scene($Acrobot)
	$Env.setup()
