extends RigidBody3D
class_name ResourceChunk

@export var chunk_resource : ResourceManager.ResourceType

@export var chunk_value : float

func _ready() -> void:
	ResourceManager.Track_Resource_Chunk(self, chunk_resource)

func DepositChunk() :
	ResourceManager.Untrack_Resource_Chunk(self, chunk_resource)
