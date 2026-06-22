extends Node3D
class_name Building

@export var max_hp : float
var current_hp : float


func _ready() -> void:
	current_hp = max_hp
