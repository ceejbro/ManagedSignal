@tool
extends Resource
class_name ManagedSignal

#Values from Object.ConnectFlags enum
@export_flags("DEFERRED", "PERSIST", "ONE_SHOT", "REFERENCE_COUNTED") var connect_flags

@export var strong_reference: bool = false:
	set(value):
		strong_reference = value

@export var autoconnect = true:
	set(value):
		autoconnect = value

@export_node_path() var source
@export var scene_source : PackedScene
