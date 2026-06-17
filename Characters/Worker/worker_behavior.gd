extends RigidBody3D
class_name Worker

enum MovementState {Waiting, Pivoting, Moving}
var move_state : MovementState

enum ActionState {None, Holding, Working} #, Fighting}
var action_state : ActionState

# TODO
# - Seperate worker behaivor into:
# - Data holder stuff used across all: State, Target
# -- Movement
# -- Inventory
# -- Working action
# -- Combat

var worker_manager : WorkerManager
 
@export_group("Debug")
@export var debug_enabled : bool
@export var debug_target : Node3D

@export_group("Nav")
@export var move_speed : float = 4
@export var nav_agent : NavigationAgent3D
@export var target : Node3D = null
var destination : Vector3
var distance_to_target : float
@export var stopping_dist : float = 1
var in_range : bool
var find_new_target : bool = false

var check_dest_cd : float = 0.25
var check_dest_timer : float = 0

# Height stuff may be very unncecssary
var height_checked : bool = false
var height_distance : float = 0.1
var worker_height : float

var current_job : WorkerManager.JobType = WorkerManager.JobType.Idle
var resource_priority : ResourceManager.ResourceType

@export_group("Chunk")
@export var hold_pos : Node3D
var held_chunk : ResourceChunk

@export var root_level_node : Node3D


func _ready() -> void:
	nav_agent.velocity_computed.connect(Callable(_on_velocity_computed))
	worker_manager = WorkerManager
	worker_manager.NewWorker(self)

### TODO self righting forces
# NOTE to self disable axis lock
#func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	#pass

func _process(delta: float) -> void:
	if debug_enabled : # Change to if target != null
		target = debug_target
		
		DebugDraw.draw_line_relative_pointy(target.global_position, global_position - target.global_position, 1, Color.BLUE_VIOLET)
		# Destination
		DebugDraw.draw_line_relative_thick(nav_agent.target_position,Vector3.UP,5,Color.LIGHT_GREEN)
	
	# Find a target now that a new job has been set
	if find_new_target :
		find_new_target = false
		match current_job :
			WorkerManager.JobType.Idle :
				#set target to command center?
				
				# TEMP rn just wander a lil
				var rand_vect : Vector3 = Vector3(randf_range(-2, 2), 0, randf_range(-2, 2))
				var random_pos : Vector3 = global_position + rand_vect
				SetDestination(GetDestFromTarget(random_pos, 0))
			WorkerManager.JobType.Gather :
				# ask what resources are needed
				#resource_priority = ResourceManager.GetMostNeededResource()
				# TEMP
				target = ResourceManager.GetClosestResourceNode(self.global_position, ResourceManager.ResourceType.values()[randi_range(0, 4)])
			WorkerManager.JobType.Logistics :
				
				# TEMP
				if held_chunk == null :
					target = ResourceManager.GetClosestResourceChunk(self.global_position, ResourceManager.ResourceType.values()[randi_range(0, 4)])
					if target != null :
						print("TARGET TARGETED? : " + str(target) + " | " + str(target.targeted))
						target.targeted = true
					else :
						find_new_target = true
				else :
					target = ResourceManager.GetClosestResourceStorage(self.global_position)
			WorkerManager.JobType.Repair :
				# Find closest (or maybe lowest hp?) damaged building
				pass
	
	# Do this while we have a target
	if target != null :
		
		if check_dest_timer < check_dest_cd :
			check_dest_timer += delta
		else :
			check_dest_timer = 0
			distance_to_target = global_position.distance_to(target.global_position)
			if distance_to_target > stopping_dist :
				in_range = false
				SetDestination(GetDestFromTarget(target.global_position, stopping_dist - 0.1))
				# Little wiggle room incase we stop short... probably means I need to change something
			else :
				in_range = true
		
		match current_job :
			WorkerManager.JobType.Idle :
				pass
			WorkerManager.JobType.Gather :
				pass
			WorkerManager.JobType.Logistics :
				if in_range and held_chunk == null :
					print("IN RANGE OF CHUNK: " + str(target))
					PickupChunk(target)
				elif in_range and held_chunk != null :
					print("IN RANGE OF STORAGE")
					target.StoreChunk(held_chunk, held_chunk.chunk_resource)
					held_chunk = null
					target = null
					in_range = false
					find_new_target = true
			WorkerManager.JobType.Repair :
				pass
	else :
		in_range = false
		# Timer
		# Look for a target a number of times
		# After long enough switch to Idle
		pass
	
	

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

func GetDestFromTarget(target_pos : Vector3, stopping_distance : float) -> Vector3 :
	var current_pos = global_position
	current_pos.y = 0
	target_pos.y = 0 # NEED TO CHANGE IF ADDING VERTICALITY
	var dir : Vector3 = current_pos - target_pos
	var dest = target_pos + (dir.normalized() * stopping_distance)
	return dest

func SetDestination(new_destination : Vector3) :
	nav_agent.target_position = new_destination

func SetJob(job : WorkerManager.JobType) :
	in_range = false
	if job == WorkerManager.JobType.Idle :
		target = null
	
	current_job = job
	find_new_target = true

func PickupChunk(chunk : ResourceChunk) :
	target = null
	in_range = false
	find_new_target = true
	
	chunk.held = true
	chunk.global_position = hold_pos.global_position
	chunk.process_mode = Node.PROCESS_MODE_DISABLED
	chunk.reparent(hold_pos)
	held_chunk = chunk

func DropChunk(chunk : ResourceChunk) :
	chunk.held = false
	chunk.process_mode = Node.PROCESS_MODE_INHERIT
	chunk.reparent(root_level_node)
	held_chunk = null

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

# bring up to helper util class
func DoRayCast(origin : Vector3, end : Vector3, length : float, can_collide_with_areas : bool) -> Dictionary :
	var result : Dictionary
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(origin, end * length)
	query.collide_with_areas = can_collide_with_areas
	result = space_state.intersect_ray(query)
	
	return result









# L
