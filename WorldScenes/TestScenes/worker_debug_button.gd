extends MenuButton

func _ready() -> void:
	get_popup().connect("id_pressed", OnPressed)

func OnPressed(id : int) :
	#print(id)
	
	var workers_array : Array[Worker] = WorkerManager.worker_dict.keys()
	
	for worker in workers_array :
		WorkerManager.AssignWorker(worker, WorkerManager.JobType.values()[id])
