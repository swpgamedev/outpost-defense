extends Node

# split job type into
# - Idle
# - Gather
# - Logistics
# - Repair
# gather can have further assigning

enum JobType {None, GatherGold, GatherWood, GatherStone, GatherIron, GatherCrystal, Logistics, Repair}

@export var worker_dict : Dictionary[Worker, int] = {}

var test_index : int = 0

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("test") :
		if test_index < JobType.size() - 1 :
			test_index+= 1
		else :
			test_index = 0
		var selected_worker : Worker = GetClosestIdleWorkerAtPos(Vector3.ZERO)
		if selected_worker != null :
			AssignWorker(selected_worker, int(JobType.values()[test_index]))
			selected_worker.target = ResourceManager.GetClosestResourceNode(selected_worker.global_position, ResourceManager.ResourceType.Gold)
		
		


func AssignWorker(selected_worker : Worker, selected_job : JobType) :
	worker_dict[selected_worker] = selected_job

func NewWorker(worker : Worker) :
	worker_dict.get_or_add(worker, JobType.None)

func GetClosestIdleWorkerAtPos(origin : Vector3) -> Worker :
	var closest_worker : Worker = null
	var shortest_distance : float = INF
	
	var workers_to_check : Array[Worker] = worker_dict.duplicate().keys()
	for check_worker in workers_to_check :
		var distance : float = origin.distance_to(check_worker.global_position)
		if distance < shortest_distance :
			shortest_distance = distance
			closest_worker = check_worker
	print("CLOSEST WORKER: " + str(closest_worker))
	return closest_worker
