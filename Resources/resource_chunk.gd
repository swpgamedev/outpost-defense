extends RigidBody3D
class_name ResourceChunk

enum ResourceType {None, Gold, Wood, Stone, Iron, Crystal}
@export var chunk_resource : ResourceType

@export var chunk_value : float

func _ready() -> void:
	ResourceManager.Track_Resource_Chunk(self)

func DepositChunk() :
	ResourceManager.Untrack_Resource_Chunk(self)
