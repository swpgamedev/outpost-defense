extends Node

enum JobType {None, GatherWood, Logistics, Repair}

@export var worker_dict : Dictionary = {Worker : JobType}




func AssignWorker(selected_worker : Worker, selected_job : JobType) : #, target : Node3D, job_to_assign : Worker.JobType
	worker_dict[selected_worker] = selected_job

func NewWorker(worker : Worker) :
	worker_dict.get_or_add(worker, JobType.None)
