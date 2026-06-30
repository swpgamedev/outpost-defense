extends Node

@export var debug_indicators : bool = true

var in_build_mode : bool = false
var mouse_pos : Vector3
var build_pos : Vector3

enum BuildingType {House, Farm, Townhall, Warehouse}

var BuildingDict : Dictionary[Building, BuildingType] = {}
var BuildingRequests : Dictionary[Building, RequestManager.Resource_Request]


func _process(_delta: float) -> void:
	if debug_indicators :
		DebugDraw.draw_line_relative_thick(build_pos, Vector3.UP, 2, Color.ORANGE)
	
	
	if Input.is_action_just_pressed("build_mode") :
		in_build_mode = !in_build_mode
	
	
	if in_build_mode :
		var results : Dictionary = Utility.MouseViewPortRayCast()
		if not results.is_empty() :
			mouse_pos = results.position
			###
			build_pos = mouse_pos
	
	

func CreateBuildingRequest(building : Building, cost : RequestManager.Resource_Cost) :
	var new_request : RequestManager.Resource_Request = RequestManager.Resource_Request.new()
	new_request = RequestManager.CreateRequest(building, cost)
	
	BuildingRequests[building] = new_request

func TrackBuilding(building : Building, building_type : BuildingType) :
	BuildingDict[building] = building_type







	#private Camera cam;
	#public float buildRange;
	#public GameObject player;
	
	#public float gridSize = 1f;
	#public LayerMask mouseLayerMask;
#
	#InputAction selectNext;
	#InputAction selectPrevious;
#
	#int selectorIndex;
#
	#public List<GameObject> buildingPrefabs;
	#public GameObject selectedBuilding;
#
#
	#public List<GameObject> ghostBuildings;
	#public GameObject ghostParent;
#
#
	#public GameObject inProgressPlaceHolder;
#
	#BuildingManager buildingManager;
#
#
	#private void Start()
	#{
#
		#cam = Camera.main;
		#buildModeAction = InputSystem.actions.FindAction("ToggleBuild");
		#clickAction = InputSystem.actions.FindAction("Attack");
#
		#selectorIndex = 0;
		#selectedBuilding = buildingPrefabs[selectorIndex];
#
		#selectNext = InputSystem.actions.FindAction("SelectNext");
		#selectPrevious = InputSystem.actions.FindAction("SelectPrevious");
#
#
		#buildingManager = BuildingManager.Instance;
#
		#player = PlayerWorkerBehavior.Instance.gameObject;
	#}
#
	#private void Update()
	#{
		#if (buildMode)
		#{
			#UpdateMouseWorldPos();
			#mouseWorldPos = new Vector3(
				#RoundToNearestGrid(mouseWorldPos.x),
				#RoundToNearestGrid(mouseWorldPos.y),
				#RoundToNearestGrid(mouseWorldPos.z));
#
			#debugIndicator.transform.position = mouseWorldPos;
#
#
			#ghostParent.transform.position = mouseWorldPos;
#
#
			#if (selectNext.WasPressedThisFrame())
			#{
				#ghostBuildings[selectorIndex].SetActive(false);
#
				#selectorIndex++;
				#if (selectorIndex >= buildingPrefabs.Count)
				#{
					#selectorIndex = 0;
				#}
				#ghostBuildings[selectorIndex].SetActive(true);
				#selectedBuilding = buildingPrefabs[selectorIndex];
#
			#}
			#if (selectPrevious.WasPressedThisFrame())
			#{
				#ghostBuildings[selectorIndex].SetActive(false);
#
				#selectorIndex--;
				#if (selectorIndex < 0)
				#{
					#selectorIndex = buildingPrefabs.Count - 1;
				#}
				#ghostBuildings[selectorIndex].SetActive(true);
				#selectedBuilding = buildingPrefabs[selectorIndex];
			#}
#
#
#
			#if (clickAction.WasPressedThisFrame())
			#{
				#BuildSelected();
			#}
		#}
#
		#if (buildModeAction.WasPressedThisFrame())
		#{
			#buildMode = !buildMode;
			#ToggleBuildMode();
		#}
#
#
	#}
#
	#void ToggleBuildMode()
	#{
		#if (buildMode)
		#{
			#ghostBuildings[selectorIndex].SetActive(true);
		#}
		#else
		#{
			#foreach (GameObject go in ghostBuildings)
			#{
				#go.SetActive(false);
			#}
		#}
	#}
#
#
	#void BuildSelected()
	#{
		#GameObject newBuilding = Instantiate(inProgressPlaceHolder, mouseWorldPos, Quaternion.identity);
		#BuildingInProgress construction = newBuilding.GetComponent<BuildingInProgress>();
		#buildingManager.buildingsInProgress.Add(construction);
#
		#construction.SetBuilding(selectedBuilding);
		#// Needs to be set based on selected building
		#construction.WorkNeeded(10);
	#}
#
	#private void UpdateMouseWorldPos()
	#{
		#Ray ray = cam.ScreenPointToRay(Input.mousePosition);
		#float maxDistance = 1000;
#
		#if (Physics.Raycast(ray, out RaycastHit hit, maxDistance, mouseLayerMask))
		#{
			#mouseWorldPos = hit.point;
		#}
#
		#Vector3 toPointVert = (mouseWorldPos - player.transform.position);
		#mouseWorldPos = player.transform.position + Vector3.ClampMagnitude(toPointVert, buildRange);
	#}
#
	#private float RoundToNearestGrid(float pos)
	#{
		#float xDiff = pos % gridSize;
		#bool isPositive = pos > 0;
		#pos -= xDiff;
		#if (Mathf.Abs(xDiff) > (gridSize / 2))
		#{
			#if (isPositive)
			#{
				#pos += gridSize;
			#}
			#else
			#{
				#pos -= gridSize;
			#}
		#}
		#return pos;
	#}
#
#
#
	#private void OnDrawGizmos()
	#{
		#Gizmos.color = Color.green;
		#Gizmos.DrawWireSphere(mouseWorldPos, 0.5f);
	#}
#}
