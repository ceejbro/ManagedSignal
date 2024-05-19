@tool
extends VBoxContainer

signal list_saved
signal list_sorted
signal item_added(item: String)
signal item_changed(from: String, to: String)
signal item_removed(item: String)
signal text_rejected(rejected_text: String)

@onready var scene_root: Control = owner

var project_settings_window
#var line_item: PackedScene = load("res://addons/gui_building_blocks/scenes/line_item.tscn")
var primary_list: GlobalSignalList = load("res://addons/signal_manager/resources/primary_global_signal_list.tres")

@onready var _refresh_loop_timer = Timer.new()

var _debug: bool = ProjectSettings.get_setting("plugins/managed_signals/debug", false)

var _pending_changes: Dictionary = {}
var _cached_text: Dictionary = {}
var _new_item_needed: bool = false
var _sort_requested: bool = false
var _sort_dirty: bool = false
var _cached_convert_case
var _end_of_list_blank: Node
var _regex = RegEx.new()

var _refresh_loop_started: bool = false
var _refresh_loop_should_run: bool = true

var delay_ms = 1000:
	get:
		if is_equal_approx(delay_ms, -1):
			return delay_ms
		else:
			return delay_ms / 1000.0
	set(value):
		if is_equal_approx(value, -1):
			delay_ms = -1
			return

		if value < 16:
			delay_ms = 16
		elif value > 60000:
			delay_ms = 60000
		else:
			delay_ms = value

func _ready() -> void:
	if _debug:
		list_saved.connect(func(): print("Saved"))
		list_sorted.connect(func(): print("Sorted"))
		item_added.connect(func(_a=null): print("Added: ", _a,))
		item_changed.connect(func(_a=null, _b=null): print("Changed from: ", _a, " to: ", _b))
		item_removed.connect(func(_a=null): print("Removed: ", _a))
		text_rejected.connect(func(a=null): print("Rejected '", a, "'"))

	if ProjectSettings.get_setting("plugins/managed_signals/automatic_refresh", true):
		delay_ms = ProjectSettings.get_setting("plugins/managed_signals/refresh_delay_milliseconds", 1000)
	else:
		delay_ms = -1

	_cached_convert_case = ProjectSettings.get_setting("plugins/managed_signals/convert_case", GlobalUtil.CaseConversions.NO_CONVERSION)
	if _cached_convert_case:
		_cached_convert_case = GlobalUtil.CaseConversions[_cached_convert_case.get_slice(" ", 0)]


	_regex.compile(ProjectSettings.get_setting("plugins/managed_signals/allowed_chars", r'^[a-zA-Z][a-zA-Z0-9_]*'))

	owner.add_child.call_deferred(_refresh_loop_timer)
	await _refresh_loop_timer.ready

	#Import current saved list
	setup_list()

	scene_root.visibility_changed.connect(_visibility_changed)
	if Engine.is_editor_hint():
		project_settings_window = scene_root.get_parent().get_parent()
		project_settings_window.visibility_changed.connect(_visibility_changed)
	else:
		project_settings_window = Control.new()
	_visibility_changed.call_deferred()

func setup_list() -> void:
	_cached_text.clear()
	_pending_changes.clear()
	_new_item_needed = false
	_sort_requested = true
	_sort_dirty = true
	primary_list.clean(_cached_convert_case)
	if get_child_count() > 0:
		for item in get_children():
			remove_child(item)
			item.queue_free()
	for item in primary_list.global_signals:
		add_item(item)
	_end_of_list_blank = add_item("")

func add_item(item: String) -> Node:
	var _modify = LineItem.new()
	_modify.first_char_regex_string = r'[a-zA-Z]*'
	_modify.disallowed_chars_regex_string = r'[^a-zA-Z0-9_]*'
	_modify.last_char_regex_string = r'[^a-zA-Z0-9]'
	_modify.TextBox.text = GlobalUtil.convert_case(item, _cached_convert_case)
	_modify.TextBox.text_changed.connect(Callable(self, "_item_text_changed").bind(_modify))
	_modify.TextBox.text_submitted.connect(Callable(self, "_item_text_changed").bind(_modify))
	_modify.TextBox.owner = _modify
	#_modify.Remove.disabled = false
	_modify.Remove.pressed.connect(Callable(self, "remove_item").bind(_modify))
	add_child(_modify)
	_cached_text[_modify] = GlobalUtil.convert_case(item, _cached_convert_case)
	if not item.is_empty():
		item_added.emit(GlobalUtil.convert_case(item, _cached_convert_case))
	else:
		_modify.Remove.disabled = true
	return _modify

func remove_item(item: Node) -> void:
	var item_text = item.TextBox.text
	primary_list.remove_item(item_text)
	_item_text_changed("", item)
	_cached_text.erase(item)
	item.queue_free()
	item_removed.emit(item_text)

func _item_text_changed(new_text: String, source: Node) -> void:
	#!!!!check if change should be rejected first
	if source == _end_of_list_blank:
		if is_equal_approx(delay_ms, -1):
			_end_of_list_blank = add_item("")
		else:
			_new_item_needed = true
	if not _pending_changes.has(source):
		_pending_changes[source] = {
			"from": _cached_text[source],
			"to": null,
		}
	if not new_text.is_empty():
		source.Remove.disabled = false
	if _cached_convert_case:
		#Note: Setting the text property does not emit the text_changed signal.
		# But it does break caret position. Needs to be reset to orignal position after text replacement.
		var caret_position = source.TextBox.caret_column
		var converted_text = primary_list.convert_case(new_text, _cached_convert_case)
		var cleaned_string = _keep_allowed_chars(converted_text)
		_pending_changes[source].to = converted_text
		source.TextBox.text = converted_text
		source.TextBox.caret_column = caret_position
	else:
		_pending_changes[source].to = new_text

func _keep_allowed_chars(input: String) -> String:
	var output: String
	var results = _regex.search(input)
	if results.subject.is_empty():
		return ""
	if results.get_end() == -1:
		text_rejected.emit(results.subject)
		return ""
	if results.subject != results.get_string():
		text_rejected.emit(results.subject.right(-results.get_end()))
		output = results.get_string()
	else:
		output = input
	return output

func _update() -> void:
	if _new_item_needed:
		_end_of_list_blank = add_item("")
		_new_item_needed = false

	if not _pending_changes.keys().is_empty():
		_sort_dirty = true

		for item in _pending_changes.keys():
			var item_index = primary_list.global_signals.find(_pending_changes[item].from)
			if item_index == -1:
				if not _pending_changes[item].to.is_empty():
					primary_list.global_signals.append(_pending_changes[item].to)
					item_added.emit(_pending_changes[item].to)
			else:
				primary_list.global_signals[item_index] = _pending_changes[item].to
				item_changed.emit(_pending_changes[item].from, _pending_changes[item].to)
			primary_list.notify_property_list_changed()
			_cached_text[item] = _pending_changes[item].to

		_pending_changes.clear()
		_save()

	if _sort_requested and _sort_dirty:
		_sort()
	_sort_requested = false

func _check_for_duplicates() -> Array[int]:
	var _duplicates: Array[int] = []
	_duplicates.resize(get_child_count())
	_duplicates.fill(0)
	for item in get_children():
		var item_index = primary_list.global_signals.find(item.TextBox.text)
		_duplicates[item_index] += 1
	return _duplicates.duplicate()

func _save() -> void:
	print("saving")
	if ResourceSaver.save(primary_list, "res://addons/signal_manager/resources/primary_global_signal_list.tres"):
		printerr("WARNING UNABLE TO SAVE CHANGES!")
	else:
		list_saved.emit()

func _sort() -> void:
	primary_list.clean(_cached_convert_case)
	var _duplicates = _check_for_duplicates()
	for item in get_children():
		var item_index = primary_list.global_signals.find(item.TextBox.text)
		if item_index == -1:
			item.queue_free()
		elif _duplicates[item_index] != 1:
			item.queue_free()
			_duplicates[item_index] -= 1
		else:
			move_child(item, item_index)
	_end_of_list_blank = add_item("")
	_sort_dirty = false
	list_sorted.emit()

func _visibility_changed(refresh_requested: bool = false) -> void:
	if refresh_requested:
		print("refresh clicked")
	if not (scene_root.visible and project_settings_window.visible) or refresh_requested:
		if not _refresh_loop_timer.is_stopped():
			print("interrupting loop")
			_refresh_loop_timer.stop()
			_refresh_loop_should_run = false
			_refresh_loop_timer.timeout.emit()
		if is_equal_approx(delay_ms, -1):
			_sort_requested = true
			_refresh()
			return
		if refresh_requested:
			_refresh_loop_started = true
			_refresh_loop_should_run = true
			_refresh()
	elif _refresh_loop_started:
		print("ignoring")
	else:
		_refresh_loop_started = true
		_refresh_loop_should_run = true
		_refresh()

func _refresh() -> void:
	if Engine.is_editor_hint() and EditorInterface.get_edited_scene_root() == scene_root:
		return

	if is_equal_approx(delay_ms, -1):
		_update()
	else:
		while _refresh_loop_should_run and scene_root.visible and project_settings_window.visible:
			print("refreshing")
			_update()
			_refresh_loop_timer.start(delay_ms)
			await _refresh_loop_timer.timeout
		_sort_requested = true
		_update()
		_refresh_loop_started = false
