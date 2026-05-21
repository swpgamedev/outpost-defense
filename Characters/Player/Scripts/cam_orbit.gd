extends Node3D

@export_group("Follow")
@export var target: CharacterBody3D
@export var offset : Vector3
@export var followSpeed : float
@export var interpolatePos : bool = true

@export_group("Orbit")
@export var camOrbitSens : float
@export var xMin : float = deg_to_rad(-75)
@export var xMax : float= deg_to_rad(75)
var rot_x : float = 0
var rot_y : float = 0

@export_group("Zoom")
@export var zoomNode: SpringArm3D
@export var zoomSens : float = 1
@export var zoomSpeed : float = 1
@export var initialZoom : Vector3 = Vector3(0, 5.5, 4.5)
@export var targetZoomPos : Vector3


func _ready() -> void:
	#target.current = is_multiplayer_authority()
	#zoomNode.current = is_multiplayer_authority()
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	targetZoomPos = initialZoom
	


func _input(event) -> void:
	if event is InputEventMouseMotion :
		rotation.x -= event.relative.y * camOrbitSens * get_process_delta_time()
		rotation.x = clampf(rotation.x, xMin, xMax)
		rotation.y += -event.relative.x * camOrbitSens * get_process_delta_time()
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_WHEEL_UP :
		targetZoomPos.x -= zoomSens * get_process_delta_time()
		targetZoomPos.y -= zoomSens * get_process_delta_time()
		targetZoomPos.z -= zoomSens * get_process_delta_time()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_WHEEL_DOWN :
		targetZoomPos.x += zoomSens * get_process_delta_time()
		targetZoomPos.y += zoomSens * get_process_delta_time()
		targetZoomPos.z += zoomSens * get_process_delta_time()
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed :
		if (Input.mouse_mode == Input.MOUSE_MODE_CAPTURED) :
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else :
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var zoomWeight := 1 - exp(-1 * zoomSpeed * delta)
	
	zoomNode.transform.origin.x = move_toward(zoomNode.transform.origin.x, targetZoomPos.x, zoomWeight)
	zoomNode.transform.origin.y = move_toward(zoomNode.transform.origin.y, targetZoomPos.y, zoomWeight)
	zoomNode.transform.origin.z = move_toward(zoomNode.transform.origin.z, targetZoomPos.z, zoomWeight)
	
	var goalPos = target.transform.origin + offset
	var t := 1 - exp(-1 * followSpeed * delta)
	
	if (interpolatePos) :
		transform.origin = transform.origin.move_toward(goalPos, t)
	else :
		transform.origin = goalPos
	
