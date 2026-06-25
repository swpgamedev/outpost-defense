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
		ResourceManager.ResourceType.Food : 0,
		ResourceManager.ResourceType.Gold : 0,
		ResourceManager.ResourceType.Wood : 0,
		ResourceManager.ResourceType.Stone : 0,
		ResourceManager.ResourceType.Iron : 0,
		ResourceManager.ResourceType.Crystal : 0
		}
	
	func UpdateByAmount(resource_type : ResourceManager.ResourceType, amount : int) : ## +/-
		cost[resource_type] = cost.values()[resource_type] + amount

func CreateResourceCost(food_val : int, gold_val : int, wood_val : int, stone_val : int, iron_val : int, crystal_val : int) -> Resource_Cost :
	var new_cost : Resource_Cost = Resource_Cost.new()
	new_cost.cost = {
		ResourceManager.ResourceType.Food : food_val,
		ResourceManager.ResourceType.Gold : gold_val,
		ResourceManager.ResourceType.Wood : wood_val,
		ResourceManager.ResourceType.Stone : stone_val,
		ResourceManager.ResourceType.Iron : iron_val,
		ResourceManager.ResourceType.Crystal : crystal_val
		}
	return new_cost

func _ready() -> void:
	
	# Dummy requests for testing
	var building2 : Building = get_tree().root.find_child("ResourceStorage", true, false)
	var test_cost2 : Resource_Cost = CreateResourceCost(1, 10, 5, 1, 1, 1)
	
	CreateRequest(building2, test_cost2)


func CreateRequest(source_building : Building, needed_resources : Resource_Cost) : ## Gold, Wood, Stone, Iron, Crystal
	var new_request : Resource_Request = Resource_Request.new()
	new_request.source_request = source_building
	new_request.missing_resources = needed_resources
	new_request.moving_resources = Resource_Cost.new()
	new_request.delivered_resources = Resource_Cost.new()
	
	existing_requests.append(new_request)


func UpdateMissingDict(request : Resource_Request, resource_type : ResourceManager.ResourceType, amount : int) :
	request.missing_resources.UpdateByAmount(resource_type, amount)
func UpdateMovingDict(request : Resource_Request, resource_type : ResourceManager.ResourceType, amount : int) :
	request.moving_resources.UpdateByAmount(resource_type, amount)
func UpdateDeilveredDict(request : Resource_Request, resource_type : ResourceManager.ResourceType, amount : int) :
	request.delivered_resources.UpdateByAmount(resource_type, amount)
	
	if request.missing_resources.cost.values().all(CheckZero) and request.moving_resources.cost.values().all(CheckZero) :
		FulfilledRequest(request)

func CheckZero(numb) :
	return numb == 0

func FulfilledRequest(request : Resource_Request) :
	request.fulfilled_request = true
	request.source_request.RequestRecieved()

## Finds closest request with something in missing
func GetClosestRequest(origin : Vector3, select_resource : bool, max_range : float = INF, resource_type : ResourceManager.ResourceType = ResourceManager.ResourceType.Food) -> Resource_Request :
	var shortest_distance : float = INF
	var closest_request: Resource_Request = null
	for i in existing_requests.size() :
		var distance : float = origin.distance_to(existing_requests[i].source_request.global_position)
		if distance > max_range :
			continue
		for resource_key : int in existing_requests[i].missing_resources.cost.keys() :
			if existing_requests[i].missing_resources.cost[resource_key] <= 0 :
				continue
			if select_resource and not resource_type :
				continue
			if distance < shortest_distance :
				shortest_distance = distance
				closest_request = existing_requests[i]
				#print("Request source: " + str(closest_request.source_request.name) + " | Distance to request: " + str(distance))
	if closest_request == null :
		print("No matching request found")
		pass
	return closest_request

## Finds first resource type thats missing for a request 
func GetClosestMissingResourceType(origin : Vector3, max_range : float = INF) -> ResourceManager.ResourceType :
	var closest_request : RequestManager.Resource_Request = GetClosestRequest(origin, false, max_range)
	var resource_to_find : ResourceManager.ResourceType
	for resource_key : int in closest_request.missing_resources.cost.keys():
		if closest_request.missing_resources.cost[resource_key] > 0 :
			resource_to_find = ResourceManager.ResourceType.values()[resource_key]
			break
	return resource_to_find








#
