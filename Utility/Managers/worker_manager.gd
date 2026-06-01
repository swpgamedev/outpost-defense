extends Node

enum JobType {None, GatherWood, Logistics, Repair}

@export var worker_dict : Dictionary = {Worker : JobType}

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("test") :
		AssignWorker(worker_dict[0], JobType.GatherWood)


func AssignWorker(selected_worker : Worker, selected_job : JobType) : #, target : Node3D, job_to_assign : Worker.JobType
	worker_dict[selected_worker] = selected_job

func NewWorker(worker : Worker) :
	worker_dict.get_or_add(worker, JobType.None)

func GetClosestIdleWorkerAtPos(origin : Vector3) : #-> Worker
	var closest_worker : Worker = null
	var shortest_distance : float = INF
	
	var workers_to_check : Array[Worker] = worker_dict.keys()
	for check_worker in workers_to_check :
		var distance : float = origin.distance_to(check_worker.global_position)
		if distance < shortest_distance :
			shortest_distance = distance
			closest_worker = check_worker
	
	#return closest_worker
