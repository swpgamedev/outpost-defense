extends Node3D

#region Debug
@export_group("Debug")
@export var debug_enabled : bool = false
@export var spherecast_indicator : CSGSphere3D
#endregion

enum SelectionStates {Disabled, Listening, Selected}
var current_state : SelectionStates

@export var select_ui : Control
@export var option_button : OptionButton
@export var ui_offset : Vector2 = Vector2(50,-50)
var selected_worker : Worker
@export var has_worker : bool = false

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
	if selected_worker != null :
		has_worker = true
	else :
		has_worker = false
	
	
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
	if Input.is_action_just_pressed("right_click") : # Need to handle inputs differently
		var results : Dictionary = MouseViewPortRayCast()
		var sphere_results : Array[Dictionary]
		
		if results.size() > 0 :
			check_pos = results.position
			
			if results.collider is Worker :
				selected_worker = results.collider
			else :
				sphere_results = TrySphereCast(check_pos, check_radius)
				
				if sphere_results.size() > 0 :
					var worker_array : Array[Worker] = []
					
					for res in sphere_results :
						if res.collider is Worker :
							worker_array.append(res.collider)
					
					if worker_array.size() == 0 :
						selected_worker = null
					elif worker_array.size() == 1 :
						selected_worker = worker_array[0]
					elif worker_array.size() > 1 :
						var origin_pos : Vector3 = results.position
						var shortest_distance : float = INF
						
						for workie in worker_array :
							var distance : float = origin_pos.distance_to(workie.global_position)
							if  distance < shortest_distance :
								shortest_distance = distance
								selected_worker = workie
		
		if selected_worker != null :
			MoveSelectUI(option_button, select_ui, selected_worker, ui_offset)
		else :
			HideSelectUI(select_ui)

func MouseViewPortRayCast() -> Dictionary :
	physics_space = get_world_3d().direct_space_state # access from root node
	var mousepos = get_viewport().get_mouse_position()
	var origin = cam.project_ray_origin(mousepos)
	var end = origin + cam.project_ray_normal(mousepos) * ray_length
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_areas = false
	
	var result = physics_space.intersect_ray(query)
	
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

func MoveSelectUI(opt_button : OptionButton, sel_ui : Control, worker : Worker, offset : Vector2) :
	opt_button.selected = worker.current_job
	sel_ui.visible = not get_viewport().get_camera_3d().is_position_behind(worker.global_transform.origin)
	sel_ui.position = get_viewport().get_camera_3d().unproject_position(worker.global_transform.origin)
	sel_ui.position += offset

func HideSelectUI(sel_ui : Control) :
	sel_ui.visible = false
	selected_worker = null

func _on_option_button_item_selected(index: int) -> void  :
	WorkerManager.AssignWorker(selected_worker, index)
	HideSelectUI(select_ui)


















# ._.
