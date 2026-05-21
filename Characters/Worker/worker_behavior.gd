extends RigidBody3D

@export_group("Debug")
@export var debug_enabled : bool
@export var debug_target : Node3D

@export_group("Nav")
@export var move_speed : float = 4
@export var nav_agent : NavigationAgent3D
@export var target : Node3D
@export var destination : Vector3
var distance_to_target : float
@export var stopping_dist : float = 1

var check_dest_cd : float = 0.25
var check_dest_timer : float = 0

# Height stuff may be very unncecssary
var height_checked : bool = false
var height_distance : float = 0.1
var worker_height : float


func _ready() -> void:
	nav_agent.velocity_computed.connect(Callable(_on_velocity_computed))


#func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	#pass

func _process(delta: float) -> void:
	if debug_enabled : # Change to if target != null
		target = debug_target
		
		DebugDraw.draw_line_relative_pointy(target.global_position,global_position - target.global_position,1,Color.BLUE_VIOLET)
		# Destination
		DebugDraw.draw_line_relative_thick(nav_agent.target_position,Vector3.UP,5,Color.LIGHT_GREEN)
	
	if target != null :
		if check_dest_timer < check_dest_cd :
			check_dest_timer += delta
		else :
			check_dest_timer = 0
			distance_to_target = global_position.distance_to(target.global_position)
			if distance_to_target > stopping_dist :
				Set_Destination(Get_Dest_From_Target(target.global_position, stopping_dist))
			

func _physics_process(_delta: float) -> void:
	if height_checked == false :
		worker_height = CheckWorkerHeight()
	
	if NavigationServer3D.map_get_iteration_id(nav_agent.get_navigation_map()) == 0 :
		return
	if nav_agent.is_navigation_finished() :
		return
	
	var next_path_pos : Vector3 = nav_agent.get_next_path_position()
	
	var no_y_dir : Vector3 = global_position.direction_to(next_path_pos)
	no_y_dir.y = 0
	
	var new_velocity : Vector3 = no_y_dir.normalized() * move_speed
	if nav_agent.avoidance_enabled :
		nav_agent.velocity = new_velocity
	else :
		_on_velocity_computed(new_velocity)
	


func _on_velocity_computed(safe_velocity : Vector3) :
	linear_velocity = safe_velocity

func Get_Dest_From_Target(target_pos : Vector3, stopping_distance : float) -> Vector3 :
	var current_pos = global_position
	current_pos.y = 0
	target_pos.y = 0 # NEED TO CHANGE IF ADDING VERTICALITY
	var dir : Vector3 = current_pos - target_pos
	destination = target_pos + (dir.normalized() * stopping_distance)
	return destination

func Set_Destination(new_destination : Vector3) :
	nav_agent.target_position = new_destination

func CheckWorkerHeight() -> float :
	var height : float = 0
	var raycast_result = DoRayCast(global_position, -global_basis.y, 10, false)
	
	if raycast_result.is_empty() :
		height_checked = false
	else :
		height = global_position.y - raycast_result.position.y
		
		nav_agent.target_desired_distance = height + (height * height_distance)
		
		height_checked = true
	
	return height

func DoRayCast(origin : Vector3, end : Vector3, length : float, can_collide_with_areas : bool) -> Dictionary :
	var result : Dictionary
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(origin, end * length)
	query.collide_with_areas = can_collide_with_areas
	result = space_state.intersect_ray(query)
	
	return result









# L
