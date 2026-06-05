extends Node

enum ResourceType {Gold, Wood, Stone, Iron, Crystal}

#region NODES AND CHUNKS
var GoldNodes : Array[ResourceNode] = []
var WoodNodes : Array[ResourceNode] = []
var StoneNodes : Array[ResourceNode] = []
var IronNodes : Array[ResourceNode] = []
var CrystalNodes : Array[ResourceNode] = []

# will defo break if moving stuff
var gold_chunk : PackedScene = preload("res://Resources/Chunks/gold_chunk.tscn")
var wood_chunk : PackedScene = preload("res://Resources/Chunks/wood_chunk.tscn")
var stone_chunk : PackedScene = preload("res://Resources/Chunks/stone_chunk.tscn")
var iron_chunk : PackedScene = preload("res://Resources/Chunks/iron_chunk.tscn")
var crystal_chunk : PackedScene = preload("res://Resources/Chunks/crystal_chunk.tscn")

var chunk_scenes : Array[PackedScene] = [gold_chunk, wood_chunk, stone_chunk, iron_chunk, crystal_chunk]

var GoldChunks : Array[ResourceChunk] = []
var WoodChunks : Array[ResourceChunk] = []
var StoneChunks : Array[ResourceChunk] = []
var IronChunks : Array[ResourceChunk] = []
var CrystalChunks : Array[ResourceChunk] = []

var nodeDict : Dictionary = {}
var chunkDict : Dictionary = {}
#endregion

#region RESOURCE REQUESTS

# OUTSTANDING = player has requested a building
var outstanding_gold_req : float
var outstanding_wood_req : float
var outstanding_stone_req : float
var outstanding_iron_req : float
var outstanding_crystal_req : float

# PENDING = resources tagged to be used for building requests (can be at site, in warehouse, or in logi worker inventory)
var pending_gold_req : float

#endregion

func _ready() -> void:
	nodeDict[0] = GoldNodes
	nodeDict[1] = WoodNodes
	nodeDict[2] = StoneNodes
	nodeDict[3] = IronNodes
	nodeDict[4] = CrystalNodes
	
	chunkDict[0] = GoldChunks
	chunkDict[1] = WoodChunks
	chunkDict[2] = StoneChunks
	chunkDict[3] = IronChunks
	chunkDict[4] = CrystalChunks

func Track_Resource_Node(new_node : ResourceNode, resource_type : ResourceType) :
	match resource_type :
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
	match resource_type :
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

func GetClosestResourceNode(origin : Vector3, resource : ResourceType) -> ResourceNode :
	var shortest_distance : float = INF
	var closest_node : ResourceNode = null
	
	var nodes_to_check : Array[ResourceNode] = nodeDict[resource]
	#print("NODES TO CHECK: " + str(nodes_to_check))
	for check_node in nodes_to_check :
		print(check_node.node_resource)
		#if check_node.node_resource
		
		
		var distance : float = origin.distance_to(check_node.global_position)
		#print("Checking this node: " + str(check_node) + ", Distance: " + str(distance))
		if distance < shortest_distance :
			#print("NEW SHORTEST")
			shortest_distance = distance
			closest_node = check_node
	
	return closest_node
























#llllllllllllllllll
