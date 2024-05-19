@tool
extends RefCounted
class_name GlobalUtil

#Enum
const CaseConversions = StringHelper.CaseConversions
const UnderscoreCases = StringHelper.UnderscoreCases
const SpaceCases = StringHelper.SpaceCases
const NoWhitepsaceCase = StringHelper.NoWhitespaceCases

static func _static_init() -> void:
	pass

static func get_builtin_type_default(type: Variant.Type) -> Variant:
	return VariantHelper.get_builtin_type_default(type)

static func convert_case(from: String, case: CaseConversions) -> String:
	return StringHelper.convert_case(from, case)

static func array_to_string(array: Array, delimiter: String = ",") -> String:
	return ArrayHelper.array_to_string(array, delimiter)
