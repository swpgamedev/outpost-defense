extends Node

var tracked_resource_nodes : Array[ResourceNode] = []
var tracked_resource_chunks : Array[ResourceChunk] = []


func Track_Resource_Node(new_node : ResourceNode) :
	tracked_resource_nodes.append(new_node)

func Track_Resource_Chunk(new_chunk : ResourceChunk) :
	tracked_resource_chunks.append(new_chunk)

func Untrack_Resource_Node(node_to_remove : ResourceNode) :
	tracked_resource_nodes.erase(node_to_remove)

func Untrack_Resource_Chunk(chunk_to_remove : ResourceChunk) :
	tracked_resource_chunks.erase(chunk_to_remove)
