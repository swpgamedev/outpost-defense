extends RigidBody3D
class_name ResourceChunk

@export var chunk_resource : ResourceManager.ResourceType
@export var chunk_value : float

var held : bool = false
var stored : bool = false
var targeted : bool = false

func _ready() -> void:
	ResourceManager.Track_Resource_Chunk(self, chunk_resource)

# Chunks will physically exist... do we want to track and untrack everytime it's stored and taken
#func DepositChunk() :
	#ResourceManager.Untrack_Resource_Chunk(self, chunk_resource)
