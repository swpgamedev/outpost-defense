extends Node

enum JobType {Idle, Gather, Logistics, Repair}
@export var worker_scene : PackedScene = preload("res://Characters/Worker/worker.tscn")

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
			AssignWorker(selected_worker, JobType.values()[test_index])
			#if JobType.values()[test_index] == JobType.Gather :
			#	AssignWorker(selected_worker, JobType.values()[test_index], ResourceManager.ResourceType.values()[some_int])
				

func AssignWorker(current_worker : Worker, selected_job : JobType) :
	worker_dict[current_worker] = selected_job
	current_worker.SetJob(selected_job)

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

func SpawnWorker(pos : Vector3, parent : Node3D, level_root : Node3D) :
	var new_worker : Worker = worker_scene.instantiate()
	add_child(new_worker)
	new_worker.global_position = pos
	new_worker.root_level_node = level_root
	new_worker.reparent(parent)












# meow
