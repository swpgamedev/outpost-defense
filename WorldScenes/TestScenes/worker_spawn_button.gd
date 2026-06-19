extends Button

@export var spawn_pos : Node3D
@export var spawn_offset : Vector3
@export var worker_parent : Node3D
@export var level_root : Node3D

func _on_pressed() -> void:
	WorkerManager.SpawnWorker(spawn_pos.global_position + spawn_offset, worker_parent, level_root)
