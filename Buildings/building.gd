extends StaticBody3D
class_name Building

@export var max_hp : float
var current_hp : float
var held_delivery_chunks : Dictionary[ResourceChunk, ResourceManager.ResourceType] = {}

func _ready() -> void:
	current_hp = max_hp


func TryTakeDelivery(chunk : ResourceChunk) :
	held_delivery_chunks[chunk] = chunk.chunk_resource
	chunk.held = false
	chunk.stored = true
	chunk.for_delivery = true
	chunk.visible = false
	chunk.global_position = self.global_position
	chunk.reparent(self)
	chunk.process_mode = Node.PROCESS_MODE_DISABLED


func RequestRecieved() :
	print("RECIEVED")
	pass


func TakeHit(damage_value : float) :
	current_hp -= damage_value
	if current_hp <= 0 :
		BuildingDie()


func BuildingDie() :
	pass
	# Need to figure out what needs to happen when a building dies




#
