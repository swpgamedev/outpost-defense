extends Node

@export var maxHP : float
@export var currentHP : float

func _ready() -> void:
	currentHP = maxHP
	

func takeHit(damageParam : float) :
	currentHP -= damageParam
	
	if (currentHP <= 0) :
		currentHP = 0
		die()
	

func die() :
	print("OOF")
	pass
