@tool
extends Resource
class_name StringHelper

#TO_TITLE_ENG, TO_SENTENCE, TO_PROPER
#to_title_eng: capitalize first word and all subsequent words unless "a/an, of, the"
#to_sentence: capitalize first word, leave remaining alone until sentence delimiter hit('.', '!', '?')
#to_proper: to_title_eng, but all words.
enum SpaceCases {
	NO_CONVERSION = 0,
	TO_LOWER = CaseConversions.TO_LOWER,
	TO_UPPER = CaseConversions.TO_UPPER,
}

enum NoWhitespaceCases {
	TO_CAMEL_CASE = CaseConversions.TO_CAMEL_CASE,
	TO_PASCAL_CASE = CaseConversions.TO_PASCAL_CASE,
}

enum UnderscoreCases {
	TO_SNAKE_CASE = CaseConversions.TO_SNAKE_CASE,
}

enum CaseConversions {
	#"the 15th item of 2D_FPS_thing is an Array" -> "the 15th item of 2D_FPS_thing is an Array"
	NO_CONVERSION,

	#"the 15th item of 2D_FPS_thing is an Array" -> "the 15th item of 2d_fps_thing is an array"
	TO_LOWER,

	#"the 15th item of 2D_FPS_thing is an Array" -> "THE 15TH ITEM OF 2D_FPS_THING IS AN ARRAY"
	TO_UPPER,

	#"the 15th item of 2D_FPS_thing is an Array" -> "the_15_th_item_of_2d_fps_thing_is_an_array"
	TO_SNAKE_CASE,

	#"the 15th item of 2D_FPS_thing is an Array" -> "the15ThItemOf2dFpsThingIsAnArray"
	TO_CAMEL_CASE,

	#"the 15th item of 2D_FPS_thing is an Array" -> "The15ThItemOf2dFpsThingIsAnArray"
	TO_PASCAL_CASE,
}

static func _static_init() -> void:
	pass

static func convert_case(from: String, case: CaseConversions) -> String:
	var to: String
	match case:
			CaseConversions.NO_CONVERSION:
				to = from
			CaseConversions.TO_LOWER:
				to = from.to_lower()
			CaseConversions.TO_UPPER:
				to = from.to_upper()
			CaseConversions.TO_SNAKE_CASE:
				to = from.to_snake_case()
			CaseConversions.TO_CAMEL_CASE:
				to = from.to_camel_case()
			CaseConversions.TO_PASCAL_CASE:
				to = from.to_pascal_case()
			_:
				printerr("How did you even get here?")
				printerr("Unknown enum value. Maybe updated or added? Making no changes.")
				to = from
	return to

