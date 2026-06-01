extends StaticBody3D
class_name ResourceNode

@export var node_resource : ResourceManager.ResourceType
var chunk_to_spawn : PackedScene

@export var chunks_left : int

func _ready() -> void:
	ResourceManager.Track_Resource_Node(self, node_resource)
	

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("jump") :
		SpawnChunk()
	

func SpawnChunk() :
	var new_chunk : ResourceChunk = load(chunk_to_spawn.resource_path).instantiate()
	add_child(new_chunk)
	new_chunk.reparent(get_parent())


func DepleteNode() :
	ResourceManager.Untrack_Resource_Node(self, node_resource)
