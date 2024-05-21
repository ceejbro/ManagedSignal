@tool
extends Resource
class_name DynamicProperty

var source: Object
var editor_data = DynamicPropertiesHelper.editor_data_template
var metadata = DynamicPropertiesHelper.metatdata_template

@export_group("Editor Data")
@export_placeholder("example_name") var property_name: String:
	set(value):
		editor_data["name"] = value
		property_name = value

@export var type: Variant.Type = TYPE_NIL:
	set(value):
		editor_data["type"] = value
		type = value
		notify_property_list_changed()

@export var property_class_name: String:
	set(value):
		editor_data["class_name"] = StringName(value)
		property_class_name = value

@export var hint: PropertyHint:
	set(value):
		editor_data["hint"] = value
		hint = value

@export var hint_string: String:
	set(value):
		editor_data["hint_string"] = value
		hint_string = value

@export_subgroup("Usage")
@export var usage_int: int = 6:
	set = _set_usage

@export_flags("DEFAULT:6","STORAGE:2","EDITOR:4","INTERNAL:8","CHECKABLE:16","CHECKED:32","GROUP:64","CATEGORY:128","SUBGROUP:256","CLASS_IS_BITFIELD:512","NO_INSTANCE_STATE:1024","RESTART_IF_CHANGED:2048","SCRIPT_VARIABLE:4096","STORE_IF_NULL:8192","UPDATE_ALL_IF_MODIFIED:16384","CLASS_IS_ENUM:65536","NIL_IS_VARIANT:131072","ARRAY:262144","ALWAYS_DUPLICATE:524288","NEVER_DUPLICATE:1048576","HIGH_END_GFX:2097152","NODE_PATH_FROM_SCENE_ROOT:4194304","RESOURCE_NOT_PERSISTENT:8388608","KEYING_INCREMENTS:16777216","EDITOR_INSTANTIATE_OBJECT:67108864","EDITOR_BASIC_SETTING:134217728","READ_ONLY:268435456","SECRET:536870912") var usage: int = PROPERTY_USAGE_DEFAULT:
	set = _set_usage

var data = {
	"editor_data": editor_data,
	"metadata": metadata,
}

func setup(setup_source: Object):
	source = setup_source

func _get_property_list() -> Array[Dictionary]:
	return [
		{
			"name": "data",
			"type": TYPE_DICTIONARY,
			"usage": PROPERTY_USAGE_STORAGE,
		},
		{
			"name": "editor_data",
			"type": TYPE_DICTIONARY,
			"usage": PROPERTY_USAGE_STORAGE,
		},
		{
			"name": "metadata",
			"type": TYPE_DICTIONARY,
			"usage": PROPERTY_USAGE_STORAGE,
		},
	]

@export_group("Metadata")
@export var visible: bool = true:
	set(value):
		metadata["visible"] = value
		visible = value

func _validate_property(property: Dictionary) -> void:
	if property.name == "property_class_name":
		if type == TYPE_OBJECT:
			property.hint = PROPERTY_HINT_ENUM_SUGGESTION
			property.hint_string = DynamicPropertiesHelper.class_hint_string
			property.usage |= PROPERTY_USAGE_EDITOR
		else:
			property_class_name = ""
			property.usage &= ~PROPERTY_USAGE_EDITOR

func _set_usage(value):
	#2 ** 32 - 2 ** 31 - 2 ** 30 - 2 ** 25 - 2 ** 15 - 1 - 1
	var allowed: int = 1040154622
	var updated = allowed & value
	usage = updated
	usage_int = updated
	editor_data["usage"] = updated
