@tool
extends RefCounted
class_name ArrayHelper

static func _static_init() -> void:
	pass

static func array_to_string(array: Array, delimiter: String = ",") -> String:
	return delimiter.join(array)
