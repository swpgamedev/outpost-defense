extends StaticBody3D
class_name ResourceNode

@export var node_resource : ResourceManager.ResourceType
var chunk_to_spawn : PackedScene
@export var spawn_offset : Vector3 = Vector3(0, 2, 0)

@export var chunks_left : int

@export var work_needed_per_chunk : float = 3
var current_work_done : float = 0

func _ready() -> void:
	ResourceManager.Track_Resource_Node(self, node_resource)
	

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("jump") :
		SpawnChunk()
	

func SpawnChunk() :
	var new_chunk : ResourceChunk = load(chunk_to_spawn.resource_path).instantiate()
	add_child(new_chunk)
	new_chunk.global_position += spawn_offset
	new_chunk.reparent(get_parent())
	
	#chunks_left -= 1

func DepleteNode() :
	ResourceManager.Untrack_Resource_Node(self, node_resource)

func TakeWork(work_amount : float) :
	current_work_done += work_amount
	if current_work_done >= work_needed_per_chunk :
		current_work_done = 0
		SpawnChunk()






















# weh
