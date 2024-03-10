extends Node2D


var current_flow_paths: Array


func _ready():
    current_flow_paths = %Paths.get_children().map(SpawnedFlow.FlowPath.new)
    SpawnedFlow.flow_paths.append_array(current_flow_paths)


func _exit_tree():
    for flow_path in current_flow_paths:
        SpawnedFlow.flow_paths.erase(flow_path)
