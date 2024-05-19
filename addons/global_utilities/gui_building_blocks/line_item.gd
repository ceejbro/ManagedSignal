@tool
extends MarginContainer
class_name LineItem

##Emitted after any characters are rejected and stripped for the first character position of the string.
##This is emitted before the general body is processed to better see which characters were rejected
##and why.
##Emitted after any characters are rejected and stripped for the general body of the string.
##This is emitted after the general body but before the last character is processed to better see which
##characters were rejected and why.
##Emitted after any characters are rejected and stripped for the last character position of the string.
##This is emitted after the last character is processed to better see which
##characters were rejected and why.
signal disallowed_characters_stripped(changes: Array[Dictionary])

##Emitted after an attempted text change results in the same string before changes were made. I.e. all added
##characters were discarded due to the RegEx filters.
signal attempted_text_change_fully_rejected

##Emitted after any text changes have been cleaned according to the RegEx expressions provided.
signal clean_text_changed(new_text: String)

const CaseConversion = GlobalUtil.CaseConversions

@export var case_convert: CaseConversion = CaseConversion.NO_CONVERSION:
		set(value):
			case_convert = value
			notify_property_list_changed()

@export var first_char_regex_string: String: set = _set_first_char_regex_string
@export var disallowed_chars_regex_string: String: set = _set_disallowed_chars_regex_string
@export var last_char_regex_string: String: set = _set_last_char_regex_string

var line_item_scene
var Warning
var TextBox
var Submit
var Remove

var _changes = []
var _first_char_regex: RegEx = RegEx.new()
var _disallowed_chars_regex: RegEx = RegEx.new()
var _last_char_regex: RegEx = RegEx.new()
var _first_char_warn: bool = false
var _disallowed_char_warn: bool = false
var _last_char_warn: bool = false

var _entry_template = {
	"pass_name": null,
	"input": null,
	"output": null,
}

func _init() -> void:
	line_item_scene = load("res://addons/global_utilities/gui_building_blocks/scenes/line_item.tscn").instantiate()
	add_child(line_item_scene)
	Warning = line_item_scene.get_node("%Warning")
	TextBox = line_item_scene.get_node("%TextBox")
	Submit = line_item_scene.get_node("%Submit")
	Remove = line_item_scene.get_node("%Remove")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not _get_configuration_warnings().is_empty():
		printerr("Check Configuration Warnings! One or more RegEx expressions did not compile.")
	Submit.text = "\u2713"
	Submit.pressed.connect(_check_allowed_chars.bind(TextBox.text, false))
	Submit.pressed.connect(_hide_submit)
	TextBox.text_submitted.connect(_check_allowed_chars.bind(false))
	TextBox.text_submitted.connect(_hide_submit.unbind(1))
	TextBox.text_changed.connect(_check_allowed_chars.bind(true))

func _hide_submit() -> void:
	Submit.visible = false

func _first_char_pass(input: String) -> String:
	var output
	if not is_instance_valid(_first_char_regex) or not _first_char_regex.is_valid():
		return input
	else:
		var fpentry = _entry_template.duplicate()
		fpentry.pass_name = "first_character"
		fpentry.input = input
		var fcresult = _first_char_regex.search(input)
		if fcresult.get_start() == -1:
			fpentry.output = ""
			fpentry.make_read_only()
			_changes.append(fpentry)
			_changes.make_read_only()
			disallowed_characters_stripped.emit(_changes.duplicate())
			attempted_text_change_fully_rejected.emit()
			output = ""
		elif fcresult.get_start() != 0:
			#We dont have to check if the input string is longer than 1 for the String.right(),
			#since a non-zero starting position implies we have more than one character and
			#at least one matched for an allowed character. It does not imply we have more than one
			#character AFTER the pass though.
			output = input.right(-fcresult.get_start())
			fpentry.output = output
			fpentry.make_read_only()
			_changes.append(fpentry)
	return output

#func _last_char_pass() -> void:
	#if is_instance_valid(last_char_regex):
#func _body_pass() -> void:
	#if is_instance_valid(disallowed_chars_regex):

func _check_allowed_chars(input: String, typing: bool) -> String:
	var output: String
	output = GlobalUtil.convert_case(input, case_convert)
	if not input.is_empty():
		output = _first_char_pass(input)
		Submit.visible = true
	else:
		Submit.visible = false
	return ""

func _get_configuration_warnings() -> PackedStringArray:
	var warnings = []
	if _first_char_warn:
		warnings.append("First Char Regex String (first_char_regex_string) is not a valid expression")
	if _disallowed_char_warn:
		warnings.append("Disallowed Char Regex String (disallowed_char_regex_string) is not a valid expression")
	if _last_char_warn:
		warnings.append("Last Char Regex String (last_char_regex_string) is not a valid expression")
	return warnings

func _set_first_char_regex_string(value):
	if value.is_empty():
		_first_char_warn = false
		_first_char_regex.clear()
	else:
		if _first_char_regex.compile(value) != OK:
			_first_char_warn = true
		else:
			_first_char_warn = false
	update_configuration_warnings()
	first_char_regex_string = value

func _set_disallowed_chars_regex_string(value):
	if value.is_empty():
		_disallowed_char_warn = false
		_disallowed_chars_regex.clear()
	else:
		if _disallowed_chars_regex.compile(value) != OK:
			_disallowed_char_warn = true
		else:
			_disallowed_char_warn = false
	update_configuration_warnings()
	disallowed_chars_regex_string = value

func _set_last_char_regex_string(value):
	if value.is_empty():
		_last_char_warn = false
		_last_char_regex.clear()
	else:
		if _last_char_regex.compile(value) != OK:
			_last_char_warn = true
		else:
			_last_char_warn = false
	update_configuration_warnings()
	last_char_regex_string = value
