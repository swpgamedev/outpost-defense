extends Node

enum JobType {Idle, Gather, Logistics, Repair}
@export var worker_scene : PackedScene = preload("res://Characters/Worker/worker.tscn")

@export var worker_dict : Dictionary[Worker, JobType] = {}

var test_index : int = 0

func _process(_delta: float) -> void:
	pass
	# Do we need to check for an existing resource request?
	# Lets do it here for now, but not every frame
	#if RequestManager.existing_requests.size() > 0 :
		# 1. Figure out what resources are needed
		# 2. Check to see if we have a chunk stored in any of our buildings
		# 3. Look in increasingly larger ranges for an untargeted chunk we need
		# 4 FAIL. If we can't find keep looping? Complain that we don't have the resource
			# 4.5 FAIL??? Move on to next request??
		# 4 SUCCESS. Send worker to grab and deliver to building/construction site
		# 5. Update what we have to pending
		# 6. Move on to next needed in current request
		# 7. Update delivered when delivered
		# 8. When everything is delivered mark as fulfilled
		# 9. Build workers should start building
	# Wow this is complicated
	
	# Maybe just have worker with logi job proiritize delivering to requests
	


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
	new_worker.name = "Worker" + str(worker_dict.size())
	new_worker.global_position = pos
	new_worker.root_level_node = level_root
	new_worker.reparent(parent)












# meow
