extends Node

var existing_requests : Array[Resource_Request]

class Resource_Request :
	# do only building need resource chunks?
	var source_request : Building
	var missing_resources : Resource_Cost
	var moving_resources : Resource_Cost
	var delivered_resources : Resource_Cost
	var fulfilled_request : bool = false

class Resource_Cost :
	var cost : Dictionary[ResourceManager.ResourceType, int] = {
		ResourceManager.ResourceType.Gold : 0,
		ResourceManager.ResourceType.Wood : 0,
		ResourceManager.ResourceType.Stone : 0,
		ResourceManager.ResourceType.Iron : 0,
		ResourceManager.ResourceType.Crystal : 0
		}
	func IncreaseResourceBy1(resource_type : ResourceManager.ResourceType) :
		cost[resource_type] = cost.values()[resource_type] + 1
	func DecreaseResourceBy1(resource_type : ResourceManager.ResourceType) :
		cost[resource_type] = cost.values()[resource_type] - 1

func CreateResourceCost(gold_val : int, wood_val : int, stone_val : int, iron_val : int, crystal_val : int) -> Resource_Cost :
	var new_cost : Resource_Cost = Resource_Cost.new()
	new_cost.cost = {
		ResourceManager.ResourceType.Gold : gold_val,
		ResourceManager.ResourceType.Wood : wood_val,
		ResourceManager.ResourceType.Stone : stone_val,
		ResourceManager.ResourceType.Iron : iron_val,
		ResourceManager.ResourceType.Crystal : crystal_val
		}
	return new_cost

func _ready() -> void:
	
	# Dummy requests for testing
	var test_building : Building = get_tree().root.find_child("TownHall", true, false)
	var worker_cost : Resource_Cost = CreateResourceCost(5, 0, 0, 0, 0)
	
	#var new_resource_dict : Dictionary = {
		#ResourceManager.ResourceType.Gold : 5,
		#ResourceManager.ResourceType.Wood : 0,
		#ResourceManager.ResourceType.Stone : 0,
		#ResourceManager.ResourceType.Iron : 0,
		#ResourceManager.ResourceType.Crystal : 0}
	
	CreateRequest(test_building, worker_cost)
	
	var building2 : Building = get_tree().root.find_child("ResourceStorage", true, false)
	var test_cost2 : Resource_Cost = CreateResourceCost(10, 5, 1, 1, 1)
	
	CreateRequest(building2, test_cost2)
	
	#print(existing_requests)
	#print(existing_requests[0].source_request.name)
	#print(existing_requests[1].source_request.name)
	
	
	#GetClosestRequestWithType(Vector3.ZERO, ResourceManager.ResourceType.Gold)




func CreateRequest(source_building : Building, needed_resources : Resource_Cost) : ## Gold, Wood, Stone, Iron, Crystal
	var new_request : Resource_Request = Resource_Request.new()
	new_request.source_request = source_building
	new_request.missing_resources = needed_resources
	new_request.moving_resources = Resource_Cost.new()
	new_request.delivered_resources = Resource_Cost.new()
	
	existing_requests.append(new_request)

func UpdateRequest(request : Resource_Request, resource_type : ResourceManager.ResourceType, delivered : bool) :
	print("*** REQUEST: " + str(request))
	print("### RESOURCE TYPE: " + str(resource_type))
	print("^^^ DELIVERED: " + str(delivered))
	
	request.missing_resources.DecreaseResourceBy1(resource_type)
	if delivered :
		request.delivered_resources.IncreaseResourceBy1(resource_type)
	else :
		request.moving_resources.IncreaseResourceBy1(resource_type)
	# decrement missing_resource by resource_type
	# increment moving_resources by resource_type if !delivered
	# increment delivered_resources by resource_type if delivered
	# NEEDS TO BE UPDATED IF THE CHUNK IS DROPPED AND WHEN DELIVERED


func FullfiledRequest() :
	pass


func GetClosestRequestWithType(origin : Vector3, resource_type : ResourceManager.ResourceType) -> Resource_Request :
	var shortest_distance : float = INF
	var closest_request: Resource_Request = null
	
	for i in existing_requests.size() :
		var distance : float = origin.distance_to(existing_requests[i].source_request.global_position)
		print(distance)
		
		for temp_key : int in existing_requests[i].missing_resources.cost.keys() :
			var temp_value : int = existing_requests[i].missing_resources.cost[temp_key]
			if temp_value > 0 and temp_key == resource_type:
				print("!!!FOUND MATCH!!!")
				if distance < shortest_distance :
					shortest_distance = distance
					closest_request = existing_requests[i]
		
	
	if closest_request == null :
		print("No matching request found")
	else :
		print("Found match at: " + str(closest_request.source_request.name))
	return closest_request











#
