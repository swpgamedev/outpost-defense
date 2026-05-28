extends StaticBody3D
class_name ResourceNode

enum ResourceType {None, Gold, Wood, Stone, Iron, Crystal}
@export var node_resource : ResourceType
@export var chunk_to_spawn : PackedScene

@export var total_chunks : int

func _ready() -> void:
	ResourceManager.Track_Resource_Node(self)
	
	

func SpawnChunk() :
	var new_chunk : ResourceChunk = load(chunk_to_spawn.resource_path).instantiate()
	add_child(new_chunk)
	new_chunk.reparent(get_parent())


func DepleteNode() :
	ResourceManager.Untrack_Resource_Node(self)
