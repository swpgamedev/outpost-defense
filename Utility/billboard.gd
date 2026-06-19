extends Node3D

@export var cam : Camera3D


func _ready() -> void:
	cam = get_viewport().get_camera_3d()
	

func _process(_delta: float) -> void:
	look_at(global_position + cam.global_basis * Vector3.FORWARD, cam.global_basis * Vector3.UP)
	#DebugDraw.draw_line_relative_pointy(global_position, cam.global_basis * Vector3.FORWARD)
