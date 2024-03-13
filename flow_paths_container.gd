extends Node2D


var current_flow_paths: Array


func create_flow_path(path: Path2D):
    return SpawnedFlow.FlowPath.new(path)


func _ready():
    current_flow_paths = get_children().map(create_flow_path)
    SpawnedFlow.flow_paths.append_array(current_flow_paths)


func _exit_tree():
    for flow_path in current_flow_paths:
        SpawnedFlow.flow_paths.erase(flow_path)
