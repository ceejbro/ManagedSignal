@tool
extends Resource
class_name GlobalSignalList

@export var global_signals: Array

func remove_item(signal_name: String) -> void:
	global_signals.erase(signal_name)
	notify_property_list_changed()

func clean(case: GlobalUtil.CaseConversions) -> void:
	global_signals = global_signals.filter(func(a): return not a.is_empty())
	global_signals = global_signals.map(func(a): return GlobalUtil.convert_case(a, case))
	global_signals = _get_unique_elements(global_signals)
	global_signals.sort_custom(func(a,b): return a.naturalnocasecmp_to(b) < 0)

func _get_unique_elements(passed_array: Array) -> Array:
	var temparray = passed_array.duplicate()
	temparray.sort()
	var previous = ""
	var item_index = 0
	for element in temparray:
		if element == previous:
			temparray[item_index] = ""
		else:
			previous = element
		item_index += 1
	temparray = temparray.filter(func(element): return true if not element.is_empty() else false)
	return temparray
