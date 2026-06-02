extends Node

enum JobType {None, GatherGold, GatherWood, GatherStone, GatherIron, GatherCrystal, Logistics, Repair}

@export var worker_dict : Dictionary[Worker, int]

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("test") :
		print("worker_dict: " + str(worker_dict))
		print("Keys: " + str(worker_dict.keys()))
		print("Values: " + str(worker_dict.values()))
		
		var selected_worker : Worker = GetClosestIdleWorkerAtPos(Vector3.ZERO)
		if selected_worker != null and worker_dict[selected_worker] != null:
			AssignWorker(selected_worker, JobType.Logistics)
		
		


func AssignWorker(selected_worker : Worker, selected_job : JobType) :
	worker_dict[selected_worker] = selected_job

func NewWorker(worker : Worker) :
	worker_dict.get_or_add(worker, JobType.None)

func GetClosestIdleWorkerAtPos(origin : Vector3) -> Worker :
	var closest_worker : Worker = null
	var shortest_distance : float = INF
	
	var workers_to_check : Array[Worker] = worker_dict.keys()
	for check_worker in workers_to_check :
		var distance : float = origin.distance_to(check_worker.global_position)
		if distance < shortest_distance :
			shortest_distance = distance
			closest_worker = check_worker
	print("CLOSEST WORKER: " + str(closest_worker))
	return closest_worker
