extends Node3D


func MouseViewPortRayCast(ray_length : float = 1000, collision_mask : int = 4294967295) -> Dictionary :
	
	var physics_space : PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var mousepos = get_viewport().get_mouse_position()
	var origin = get_viewport().get_camera_3d().project_ray_origin(mousepos)
	var end = origin + get_viewport().get_camera_3d().project_ray_normal(mousepos) * ray_length
	var query = PhysicsRayQueryParameters3D.create(origin, end, collision_mask)
	query.collide_with_areas = false
	
	var result = physics_space.intersect_ray(query)
	
	return result
