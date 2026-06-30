extends RigidBody3D
class_name Worker

enum MovementState {Waiting, Pivoting, Moving}
var move_state : MovementState

enum ActionState {None, Holding, Working} #, Fighting}
var action_state : ActionState

# TODO
# - Seperate worker behaivor into:
# - Data holder stuff used across all: State, Target, Stats
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
@export var target : Node3D
var distance_to_target : float
@export var stopping_dist : float = 1
@export var worker_range : float = 1.5
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
var resource_request : RequestManager.Resource_Request

@export_group("Idle")
@export var idle_wait_max : float = 3
@export var idle_wait_min : float = 0.5
var idle_wait_cooldown : float
var idle_wait_timer : float
@export var idle_wander_distance_max : float = 3
@export var idle_wander_distance_min : float = -3
var wander_distance : float
var idle_waiting : bool = false
var idle_wandering : bool = false

@export_group("Work Work")
@export var work_cooldown : float = 1
var work_timer : float = 0
@export var work_amount : float = 1
var can_do_work : bool = false

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
		#target = debug_target
		if target != null :
			DebugDraw.draw_line_relative_pointy(target.global_position, global_position - target.global_position, 1, Color.BLUE_VIOLET)
			# Destination
			DebugDraw.draw_line_relative_thick(nav_agent.target_position,Vector3.UP,5,Color.LIGHT_GREEN)
	
	# Find a target now that a new job has been set
	if find_new_target :
		find_new_target = false
		match current_job :
			WorkerManager.JobType.Idle :
				print("IDLE TARGETING")
				#set target to command center?
				
				# TEMP rn just wander a lil
				#if idle_waiting :
				
				
				idle_wait_cooldown = randf_range(idle_wait_min, idle_wait_max)
				idle_wait_timer = 0
				wander_distance = randf_range(idle_wander_distance_min, idle_wander_distance_max)
				
				idle_waiting = true
				idle_wandering = false
				
				var rand_dir : Vector3 = Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)).normalized()
				var random_pos : Vector3 = global_position + (rand_dir * wander_distance)
				SetDestination(GetDestFromTarget(random_pos, 0))
			
			WorkerManager.JobType.Gather :
				print("GATHER TARGETING")
				# ask what resources are needed
				#resource_priority = ResourceManager.GetResourcePriority() ## Array? start top prio to last bottom prio?
				# TEMP ### At some point need to prioritize resource type instead of random
				target = ResourceManager.GetClosestResourceNode(self.global_position, ResourceManager.ResourceType.values()[randi_range(0, ResourceManager.ResourceType.size() - 1)])
			
			WorkerManager.JobType.Logistics :
				print("LOGISTICS TARGETING")
				# TEMP ### At some point need to prioritize resource type instead of random
				var resource_to_find : ResourceManager.ResourceType
				var outstanding_requests : bool = RequestManager.existing_requests.size() > 0
				
				if outstanding_requests :
					resource_to_find = RequestManager.GetClosestMissingResourceType(global_position)
					resource_priority = resource_to_find
				
				# Lets try and find a chunk
				if held_chunk == null :
					# If request exists, look for the closest chunk
					
					if outstanding_requests :
						target = ResourceManager.GetClosestResourceChunk(
							global_position,
							resource_to_find,
							true,
							false)
						if target == null : ## Can't find chunks of type, need to grab something else
							pass
					else :
						target = ResourceManager.GetClosestResourceChunk(
							global_position,
							ResourceManager.ResourceType.values()[randi_range(0, ResourceManager.ResourceType.size() - 1)],
							true,
							true)
					
					if target != null :
						print("TARGET TARGETED? : " + str(target) + " | " + str(target.targeted))
						target.targeted = true
						find_new_target = false
					else :
						find_new_target = true
				else :
					# We are holding a chunk and need to decide where it goes
					if RequestManager.existing_requests.size() > 0 :
						var request : RequestManager.Resource_Request = RequestManager.GetClosestRequest(global_position, held_chunk.chunk_resource)
						if request != null :
							resource_request = request
							target = request.source_request
							RequestManager.UpdateMissingDict(request, held_chunk.chunk_resource, -1)
							RequestManager.UpdateMovingDict(request, held_chunk.chunk_resource, 1)
						else :
							resource_request = null
							target = ResourceManager.GetClosestResourceStorage(self.global_position)
					else :
						target = ResourceManager.GetClosestResourceStorage(self.global_position)
			
			WorkerManager.JobType.Repair :
				# Find closest (or maybe lowest hp?) damaged building
				pass
	
	# Do this while we have a target
	if target != null :
		distance_to_target = global_position.distance_to(target.global_position)
		if distance_to_target > worker_range + (worker_height / 2) :
			in_range = false
		else :
			in_range = true
		
		if check_dest_timer < check_dest_cd :
			check_dest_timer += delta
		else :
			check_dest_timer = 0
			if distance_to_target > stopping_dist :
				SetDestination(GetDestFromTarget(target.global_position, stopping_dist))

		
		match current_job :
			WorkerManager.JobType.Idle :
				# We shouldn't have a target if we're idle...
				push_error("We are Idle but have a target... | " + str(self.name))
				print_debug("")
				pass
			
			WorkerManager.JobType.Gather :
				print("GATHER DOING")
				if in_range :
					if work_timer < work_cooldown :
						work_timer += delta
					else :
						work_timer = 0
						can_do_work = true
				
				if can_do_work :
					target.TakeWork(work_amount)
					can_do_work = false
			
			WorkerManager.JobType.Logistics :
				print("LOGISTICS DOING")
				if in_range and held_chunk == null :
					print("IN RANGE OF CHUNK: " + str(target))
					PickupChunk(target)
				elif in_range and resource_request != null and held_chunk != null :
					if target is Building :
						print("ITS A BUILDING")
						DeliverChunk(target, held_chunk, resource_request)
						
					else :
						push_error("ERM... trying to deliver to something thats not a building")
				elif in_range and held_chunk != null :
					
					if target is ResourceStorage :
						print("IN RANGE OF STORAGE")
						target.StoreChunk(held_chunk, held_chunk.chunk_resource)
						held_chunk = null
						target = null
						in_range = false
						find_new_target = true
					else :
						print("Not a resource storage..")
			
			WorkerManager.JobType.Repair :
				pass
	else :
		in_range = false
		
		# we do a little bit of wandering
		if current_job == WorkerManager.JobType.Idle :
			if idle_waiting :
				idle_wait_timer += delta
				if idle_wait_timer > idle_wait_cooldown :
					idle_wait_timer = 0
					idle_waiting = false
					idle_wandering = true
			elif idle_wandering :
				if nav_agent.is_navigation_finished() :
					idle_wandering = false
					find_new_target = true
		
		# Maybe add another timer when on other jobs
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
	if target != null and target is ResourceChunk :
		target.targeted = false
	if held_chunk != null :
		DropChunk(held_chunk)
	in_range = false
	target = null
	resource_request = null
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
	target = null
	in_range = false
	find_new_target = true
	if resource_request != null :
		# If resource_request fails here... maybe need to remove these pending deliveries when the request is cancelled
		RequestManager.UpdateMovingDict(resource_request, chunk.chunk_resource, -1)
		RequestManager.UpdateMissingDict(resource_request, chunk.chunk_resource, 1)
		resource_request = null
	chunk.held = false
	chunk.process_mode = Node.PROCESS_MODE_INHERIT
	chunk.targeted = false
	chunk.reparent(root_level_node)
	held_chunk = null

func DeliverChunk(building : Building, chunk : ResourceChunk, request : RequestManager.Resource_Request) :
	building.TryTakeDelivery(held_chunk)
	
	target = null
	in_range = false
	find_new_target = true
	if resource_request != null :
		# If resource_request fails here... maybe need to remove these pending deliveries when the request is cancelled
		RequestManager.UpdateMovingDict(request, chunk.chunk_resource, -1)
		RequestManager.UpdateDeilveredDict(request , chunk.chunk_resource, 1)
		resource_request = null
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
