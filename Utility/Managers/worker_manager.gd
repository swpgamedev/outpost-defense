extends Node

enum JobType {Idle, Gather, Logistics, Repair}

@export var worker_dict : Dictionary[Worker, JobType] = {}

var test_index : int = 0

func _process(_delta: float) -> void:
	
	### ALL FOR SILLY TESTING :))
	if Input.is_action_just_pressed("test") :
		if test_index < JobType.size() - 1 :
			test_index+= 1
		else :
			test_index = 0
		var selected_worker : Worker = GetClosestIdleWorkerAtPos(Vector3.ZERO)
		if selected_worker != null :
			var rand_int : int = randi_range(0, ResourceManager.ResourceType.size() - 1)
			if JobType.values()[test_index] == JobType.Gather :
				AssignWorker(selected_worker, JobType.values()[test_index], ResourceManager.ResourceType.values()[rand_int], true)
			else :
				AssignWorker(selected_worker, JobType.values()[test_index], ResourceManager.ResourceType.values()[rand_int], false)

func AssignWorker(current_worker : Worker, selected_job : JobType, resource : ResourceManager.ResourceType, set_target : bool) :
	worker_dict[current_worker] = selected_job
	current_worker.current_job = selected_job
	
	if selected_job == JobType.Idle :
		# set to chill or go back to base?
		gg.print("Idle")
		pass
	elif selected_job == JobType.Gather :
		# start gather loop, set resource to try to work on
		gg.print("Gather")
		if set_target :
			current_worker.target = ResourceManager.GetClosestResourceNode(current_worker.global_position, resource)
	elif selected_job == JobType.Logistics :
		# start logistics loop
		gg.print("Logistics")
		pass
	elif selected_job == JobType.Repair :
		# start repair loop
		gg.print("Repair")
		pass

func NewWorker(worker : Worker) :
	worker_dict.get_or_add(worker, JobType.Idle)

func GetClosestIdleWorkerAtPos(origin : Vector3) -> Worker :
	var closest_worker : Worker = null
	var shortest_distance : float = INF
	
	var workers_array : Array[Worker] = worker_dict.duplicate().keys()
	print("WORKERS ARRAY: " + str(workers_array))
	var test : int = 0
	
	for check_worker in workers_array :
		test += 1
		print(str(test) + " : " + str(check_worker) + " -- " + str(worker_dict[check_worker]))
		if worker_dict[check_worker] == JobType.Idle :
			print(str(test) + " IDLE")
			
			
			var distance : float = origin.distance_to(check_worker.global_position)
			if distance < shortest_distance :
				shortest_distance = distance
				closest_worker = check_worker
	print("CLOSEST WORKER: " + str(closest_worker))
	return closest_worker














# meow
