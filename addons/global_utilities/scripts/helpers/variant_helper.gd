@tool
extends Resource
class_name VariantHelper


static func get_builtin_type_default(type: Variant.Type) -> Variant:
	match type:
		#Edge Case for type_convert(null, String), we want String().
		#Satisfies .is_empty() and returns the empty string "".
		TYPE_STRING:
			return String()
		#Memory Management?
		TYPE_OBJECT:
			return Object.new()
		_:
			return type_convert(null, type)

