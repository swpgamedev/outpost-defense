extends Node

enum ResourceType {Food, Gold, Wood, Stone, Iron, Crystal}

#region NODES AND CHUNKS
var FoodNodes : Array[ResourceNode] = []
var GoldNodes : Array[ResourceNode] = []
var WoodNodes : Array[ResourceNode] = []
var StoneNodes : Array[ResourceNode] = []
var IronNodes : Array[ResourceNode] = []
var CrystalNodes : Array[ResourceNode] = []

# will defo break if moving stuff
var food_chunk : PackedScene = preload("res://Resources/Chunks/food_chunk.tscn")
var gold_chunk : PackedScene = preload("res://Resources/Chunks/gold_chunk.tscn")
var wood_chunk : PackedScene = preload("res://Resources/Chunks/wood_chunk.tscn")
var stone_chunk : PackedScene = preload("res://Resources/Chunks/stone_chunk.tscn")
var iron_chunk : PackedScene = preload("res://Resources/Chunks/iron_chunk.tscn")
var crystal_chunk : PackedScene = preload("res://Resources/Chunks/crystal_chunk.tscn")

#var chunk_scenes : Array[PackedScene] = [food_chunk, gold_chunk, wood_chunk, stone_chunk, iron_chunk, crystal_chunk]

var FoodChunks : Array[ResourceChunk] = []
var GoldChunks : Array[ResourceChunk] = []
var WoodChunks : Array[ResourceChunk] = []
var StoneChunks : Array[ResourceChunk] = []
var IronChunks : Array[ResourceChunk] = []
var CrystalChunks : Array[ResourceChunk] = []

var nodeDict : Dictionary = {}
var chunkDict : Dictionary = {}

var allNodes : Array[ResourceNode]
#endregion

var ResourceStorages : Array[ResourceStorage] = []
var TownHalls : Array[Building] = []

func _ready() -> void:
	nodeDict[0] = FoodNodes
	nodeDict[1] = GoldNodes
	nodeDict[2] = WoodNodes
	nodeDict[3] = StoneNodes
	nodeDict[4] = IronNodes
	nodeDict[5] = CrystalNodes
	
	chunkDict[0] = FoodChunks
	chunkDict[1] = GoldChunks
	chunkDict[2] = WoodChunks
	chunkDict[3] = StoneChunks
	chunkDict[4] = IronChunks
	chunkDict[5] = CrystalChunks

func Track_Resource_Node(new_node : ResourceNode, resource_type : ResourceType) :
	allNodes.append(new_node)
	match resource_type :
		ResourceType.Food :
			FoodNodes.append(new_node)
			new_node.chunk_to_spawn = food_chunk
		ResourceType.Gold :
			GoldNodes.append(new_node)
			new_node.chunk_to_spawn = gold_chunk
		ResourceType.Wood :
			WoodNodes.append(new_node)
			new_node.chunk_to_spawn = wood_chunk
		ResourceType.Stone :
			StoneNodes.append(new_node)
			new_node.chunk_to_spawn = stone_chunk
		ResourceType.Iron :
			IronNodes.append(new_node)
			new_node.chunk_to_spawn = iron_chunk
		ResourceType.Crystal :
			CrystalNodes.append(new_node)
			new_node.chunk_to_spawn = crystal_chunk

func Untrack_Resource_Node(node_to_remove : ResourceNode, resource_type : ResourceType) :
	allNodes.erase(node_to_remove)
	match resource_type :
		ResourceType.Food :
			FoodNodes.erase(node_to_remove)
		ResourceType.Gold :
			GoldNodes.erase(node_to_remove)
		ResourceType.Wood :
			WoodNodes.erase(node_to_remove)
		ResourceType.Stone :
			StoneNodes.erase(node_to_remove)
		ResourceType.Iron :
			IronNodes.erase(node_to_remove)
		ResourceType.Crystal :
			CrystalNodes.erase(node_to_remove)

func Track_Resource_Chunk(new_chunk : ResourceChunk, resource_type : ResourceType) :
	match resource_type :
		ResourceType.Food :
			FoodChunks.append(new_chunk)
		ResourceType.Gold :
			GoldChunks.append(new_chunk)
		ResourceType.Wood :
			WoodChunks.append(new_chunk)
		ResourceType.Stone :
			StoneChunks.append(new_chunk)
		ResourceType.Iron :
			IronChunks.append(new_chunk)
		ResourceType.Crystal :
			CrystalChunks.append(new_chunk)

func Untrack_Resource_Chunk(chunk_to_remove : ResourceChunk,  resource_type : ResourceType) :
	match resource_type :
		ResourceType.Food :
			FoodChunks.erase(chunk_to_remove)
		ResourceType.Gold :
			GoldChunks.erase(chunk_to_remove)
		ResourceType.Wood :
			WoodChunks.erase(chunk_to_remove)
		ResourceType.Stone :
			StoneChunks.erase(chunk_to_remove)
		ResourceType.Iron :
			IronChunks.erase(chunk_to_remove)
		ResourceType.Crystal :
			CrystalChunks.erase(chunk_to_remove)

func Track_Resource_Storage(new_storage : ResourceStorage) :
	ResourceStorages.append(new_storage)

func Untrack_Resource_Storage(storage_to_remove : ResourceStorage) :
	ResourceStorages.erase(storage_to_remove)

func Track_TownHall(townhall : Building) :
	TownHalls.append(townhall)

func Untrack_TownHall(townhall : Building) :
	TownHalls.erase(townhall)

# Could make generic find closest variant
# Would need some if's to filter chunks or nodes

func GetClosestResourceNode(origin : Vector3, resource : ResourceType) -> ResourceNode :
	var shortest_distance : float = INF
	var closest_node : ResourceNode = null
	var nodes_to_check : Array[ResourceNode] = nodeDict[resource]
	for check_node in nodes_to_check :
		var distance : float = origin.distance_to(check_node.global_position)
		if distance < shortest_distance :
			shortest_distance = distance
			closest_node = check_node
	return closest_node


func GetClosestResourceChunk(origin : Vector3, resource : ResourceType, filter_targeted : bool, filter_stored : bool, max_distance : float = INF) -> ResourceChunk : ## Filter out
	var shortest_distance : float = INF # replace with max_range var?
	var closest_chunk : ResourceChunk = null
	for check_chunk : ResourceChunk in chunkDict[resource] :
		if check_chunk.for_delivery :
			print("DELIVERY FILTER OUT")
			continue
		if not check_chunk.chunk_resource == resource :
			continue
		else :
			if filter_targeted and check_chunk.targeted :
				continue
			if filter_stored and check_chunk.stored:
				continue
			var distance : float = origin.distance_to(check_chunk.global_position)
			if distance < max_distance and distance < shortest_distance:
					shortest_distance = distance
					closest_chunk = check_chunk
	return closest_chunk


func GetClosestResourceStorage(origin : Vector3) -> ResourceStorage :
	var shortest_distance : float = INF
	var closest_storage : ResourceStorage = null
	var storage_to_check : Array[ResourceStorage] = ResourceStorages
	for check_storage in storage_to_check :
		var distance : float = origin.distance_to(check_storage.global_position)
		if distance < shortest_distance :
			shortest_distance = distance
			closest_storage = check_storage
	return closest_storage




















#llllllllllllllllll
