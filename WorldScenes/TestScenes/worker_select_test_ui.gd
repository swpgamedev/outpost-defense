extends Node3D

#region Debug
@export_group("Debug")
@export var debug_enabled : bool = false
@export var spherecast_indicator : CSGSphere3D
#endregion

enum SelectionStates {Disabled, Listening, Selected}
var current_state : SelectionStates

var selected_worker : Worker

var cam : Camera3D

@export var ray_length : float = 1000
@export var check_radius : float = 2

var check_pos : Vector3

# PHYSICS
var physics_space : PhysicsDirectSpaceState3D # Needs to be updated when things are moved

func _ready() -> void:
	cam = get_viewport().get_camera_3d()
	pass

func _process(_delta: float) -> void:
	if debug_enabled :
		if spherecast_indicator.visible == false :
			spherecast_indicator.visible = true
		
		var vect1 : Vector3 = Vector3(cam.position.x, cam.position.y - 1, cam.position.z)
		var vect2 : Vector3 = Vector3(check_pos.x, check_pos.y - cam.position.y + 1, check_pos.z)
		DebugDraw.draw_line_relative_pointy(vect1, vect2, 1, Color.SKY_BLUE)
		
		DebugDraw.draw_line_relative_thick(check_pos, Vector3.UP, 2, Color.CYAN)
		
		if spherecast_indicator.radius != check_radius :
			spherecast_indicator.radius = check_radius
		spherecast_indicator.position = check_pos
	else :
		if spherecast_indicator.visible :
			spherecast_indicator.visible = false


func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("left_click") : # Need to handle inputs differently
		var results : Dictionary = MouseViewPortRayCast()
		var sphere_results : Array[Dictionary]
		
		if results.size() > 0 :
			check_pos = results.position
			
			if results.collider is Worker :
				selected_worker = results.collider
			else :
				sphere_results = TrySphereCast(check_pos, check_radius)
				var i : int = 0
				for dict in sphere_results :
					print(dict.collider)
					if dict.collider is Worker :
						print("HORRAY")
					
					print(str(i) + ": " + str(sphere_results[i]))
					i += 1

func MouseViewPortRayCast() -> Dictionary :
	physics_space = get_world_3d().direct_space_state # access from root node
	var mousepos = get_viewport().get_mouse_position()
	var origin = cam.project_ray_origin(mousepos)
	var end = origin + cam.project_ray_normal(mousepos) * ray_length
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_areas = false
	
	var result = physics_space.intersect_ray(query)
	
	print("RESULT: " + str(result))
	
	return result

### Throw sphere shape at raycast point if we only collide with ground
### Use this new query to find a nearby worker
func TrySphereCast(pos : Vector3, radius : float) -> Array[Dictionary] :
	physics_space = get_world_3d().direct_space_state
	
	var shape_rid = PhysicsServer3D.sphere_shape_create()
	PhysicsServer3D.shape_set_data(shape_rid, radius)
	
	
	var params = PhysicsShapeQueryParameters3D.new()
	params.shape_rid = shape_rid
	params.transform.origin = pos
	
	# Execute physics queries here...
	var result = physics_space.intersect_shape(params)
	
	return result
	
	# Release the shape when done with physics queries.
	#PhysicsServer3D.free_rid(shape_rid)
	# Do we need to release this shape ever?


func _on_option_button_item_selected(index: int) -> void:
	print("SELECTED: " + str(index))
