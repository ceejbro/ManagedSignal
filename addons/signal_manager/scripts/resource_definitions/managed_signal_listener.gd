@tool
extends Resource
class_name ManagedSignalListener

enum FlagModes {
	OVERRIDE,
	MERGE,
}

@export var flag_mode: FlagModes = FlagModes.OVERRIDE

#Values from Object.ConnectFlags enum
@export_flags("DEFERRED", "PERSIST", "ONE_SHOT", "REFERENCE_COUNTED") var connect_flags

@export var strong_reference: bool = false:
	set(value):
		strong_reference = value

@export var autoconnect = true:
	set(value):
		autoconnect = value
