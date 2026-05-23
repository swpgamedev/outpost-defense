extends StaticBody3D
class_name ResourceNode

enum ResourceType {None, Gold, Wood, Stone, Iron, Crystal}
@export var node_resource : ResourceType

@export var chunks_avaliable : int

func _ready() -> void:
	ResourceManager.Track_Resource_Node(self)

func DepleteNode() :
	ResourceManager.Untrack_Resource_Node(self)
