@tool
extends RefCounted
class_name DynamicPropertiesHelper

static var class_hint_string = GlobalUtil.array_to_string(
	PackedStringArray(ProjectSettings.get_global_class_list().map(func(a): return a.class)) + \
	ClassDB.get_class_list()
)

static var editor_data_template: Dictionary = {
	"name": "",
	"class_name": StringName(),
	"type": TYPE_NIL,
	"hint": PROPERTY_HINT_NONE,
	"hint_string": "",
	"usage": PROPERTY_USAGE_DEFAULT,
}:
	get:
		#returns a copy for editing rather than the template
		return editor_data_template.duplicate()
	set(value):
		return

static var metatdata_template: Dictionary = {
	"previous_value": null,
	"value": null,
	"get": Callable(),
	"set": Callable(),
	"visible": true,
	"reset_on_hide": true,
	"default": null,
	"notify_on_change": false,
	"before_notify": Callable(),
	"after_notify": Callable(),
	"description": "",
}:
	get:
		return metatdata_template.duplicate()
	set(value):
		return

static func _static_init() -> void:
	pass

static func helper_get(property: StringName, exposed_properties: Dictionary) -> Variant:
	if exposed_properties.has(property):
		if exposed_properties[property]["get"]:
			return exposed_properties[property]["get"].call()
		return exposed_properties[property].value
	return null

static func helper_set(value) -> void:
	pass

static func helper_property_can_revert():
	pass

static func helper_property_get_revert():
	pass

static func helper_get_property_list():
	pass

static func helper_validate_property():
	pass

static func get_metatdata():
	pass
