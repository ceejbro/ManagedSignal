@tool
extends Resource
class_name ProjectSettingsProperty

#expand out into sidebar category / sidebar settings group / settings category / setting name
@export var path: String = "plugins/managed_signals/convert_case"

@export_category("Property Info")
@export var type: Variant.Type = TYPE_NIL:
	set(value):
		if value:
			_initial_value_visible = true
			_class_name_visible = false
			if value != type:
				_exposed_properties["initial_value"].value = VariantHelper.get_builtin_type_default(value)
				_exposed_properties["initial_value"].default = VariantHelper.get_builtin_type_default(value)
				notify_property_list_changed()
			if value == TYPE_OBJECT:
				_class_name_visible = true
			type = value
		if not value or value == TYPE_NIL:
			type = value
			_exposed_properties["initial_value"].value = null
			_exposed_properties["initial_value"].default = null
			_initial_value_visible = false
			_class_name_visible = false
			notify_property_list_changed()
			
@export var hint: PropertyHint
@export var hint_string: String

var _initial_value_visible = false
var _class_name_visible = false
var _class_hint_string: String = ",".join(
	PackedStringArray(["FROM_SCRIPT"]) + \
	PackedStringArray(ProjectSettings.get_global_class_list().map(func(a): return a.class)) + \
	ClassDB.get_class_list()
)
var _exposed_properties: Dictionary = {
	"class_name": {
		"default": StringName(),
		"value": StringName(),
	},
	"initial_value": {
		"default": null,
		"value": null,
	},
	"internal": {
		"default": false,
		"value": false,
	},
	"basic": {
		"default": true,
		"value": true,
	},
	"restart_if_changed": {
		"default": false,
		"value": false,
	},
}

func _get(property: StringName) -> Variant:
	return DynamicPropertiesHelper.helper_get(property, _exposed_properties)

func _set(property: StringName, value: Variant) -> bool:
	if property == "class_name":
		_exposed_properties["class_name"].value = value
		notify_property_list_changed()

	if _exposed_properties.has(property):
		_exposed_properties[property].value = value
		return true
	return false

func _property_can_revert(property: StringName) -> bool:
	return _exposed_properties.has(property)

func _property_get_revert(property: StringName) -> Variant:
	if _exposed_properties.has(property):
		return _exposed_properties[property].default
	return null

func _get_property_list() -> Array[Dictionary]:
	var property_array: Array[Dictionary]
	if _class_name_visible:
		property_array.append({
			"name": "class_name",
			"type": TYPE_STRING,
			"hint": PROPERTY_HINT_ENUM,
			"hint_string": _class_hint_string,
		})
		property_array.append({
			"name": "initial_value",
			"class_name": StringName(get("class_name")),
			"type": type,
			"hint": PROPERTY_HINT_RESOURCE_TYPE,
			"hint_string": StringName(get("class_name")),
		})
	elif _initial_value_visible:
		property_array.append({
			"name": "initial_value",
			"type": type,
		})
	print(get("initial_value"))
	property_array.append({
		"name": "internal",
		"type": TYPE_BOOL,
	})
	property_array.append({
		"name": "basic",
		"type": TYPE_BOOL,
	})
	property_array.append({
		"name": "restart_if_changed",
		"type": TYPE_BOOL,
	})
	notify_property_list_changed()
	return property_array
