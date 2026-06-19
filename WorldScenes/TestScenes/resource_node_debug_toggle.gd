extends Button

var debug_on : bool

func _on_pressed() -> void:
	debug_on = !debug_on
	
	for resource_node in ResourceManager.allNodes :
			resource_node.debug_enabled = debug_on
	
