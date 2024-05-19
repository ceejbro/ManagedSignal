@tool
extends EditorPlugin

var panel_scene
var project_scene
var settings: Dictionary = {
		"plugins/managed_signals/debug" : {
			"property_info" : {
				"name": "plugins/managed_signals/debug",
				"type": TYPE_BOOL,
			},
			"initial_value": false,
			"internal": false,
			"basic": false,
			"restart_if_changed": true,
		},
		"plugins/managed_signals/convert_case": {
			"property_info" : {
				"name": "plugins/managed_signals/convert_case",
				"type": TYPE_STRING,
				"hint": PROPERTY_HINT_ENUM,
				"hint_string": "NO_CONVERSION,TO_LOWER,TO_UPPER,TO_SNAKE_CASE (GDScript Style),TO_CAMEL_CASE,TO_PASCAL_CASE",
			},
			"initial_value": "TO_SNAKE_CASE (GDScript Style)",
			"internal": false,
			"basic": true,
			"restart_if_changed": false,
		},
		"plugins/managed_signals/automatic_refresh" : {
			"property_info" : {
				"name": "plugins/managed_signals/automatic_refresh",
				"type": TYPE_BOOL,
			},
			"initial_value": true,
			"internal": false,
			"basic": true,
			"restart_if_changed": true,
		},
		"plugins/managed_signals/refresh_delay_milliseconds" : {
			"property_info" : {
				"name": "plugins/managed_signals/refresh_delay_milliseconds",
				"type": TYPE_INT,
				"hint": PROPERTY_HINT_RANGE,
				"hint_string": "100,60000,100"
			},
			"initial_value": 1000,
			"internal": false,
			"basic": true,
			"restart_if_changed": true,
		},
		"plugins/managed_signals/signal_list" : {
			"property_info" : {
				"name": "plugins/managed_signals/signal_list",
				"type": TYPE_ARRAY,
			},
			"initial_value": [],
			"internal": true,
			"basic": false,
			"restart_if_changed": false,
		},
		"plugins/managed_signals/allowed_first_char" : {
			"property_info" : {
				"name": "plugins/managed_signals/allowed_first_char",
				"type": TYPE_STRING,
			},
			"initial_value": r'[a-zA-Z]*',
			"internal": false,
			"basic": false,
			"restart_if_changed": true,
		},
		"plugins/managed_signals/chars_to_filter_out" : {
			"property_info" : {
				"name": "plugins/managed_signals/chars_to_filter_out",
				"type": TYPE_STRING,
			},
			"initial_value": r'[^a-zA-Z0-9_]*',
			"internal": false,
			"basic": false,
			"restart_if_changed": true,
		},
	}

func _enter_tree():
	panel_scene = load("res://addons/signal_manager/scenes/dock_lower_left/control.tscn").instantiate()
	project_scene = load("res://addons/signal_manager/scenes/project_settings_tab/proj.tscn").instantiate()

	for setting in settings.keys():
		if not ProjectSettings.has_setting(setting):
			ProjectSettings.set_setting(setting, settings[setting].initial_value)
			ProjectSettings.add_property_info(settings[setting].property_info)
			ProjectSettings.set_initial_value(setting, settings[setting].initial_value)
			ProjectSettings.set_as_internal(setting, settings[setting].internal)
			ProjectSettings.set_as_basic(setting, settings[setting].basic)
			ProjectSettings.set_restart_if_changed(setting, settings[setting].restart_if_changed)
	var save_err = ProjectSettings.save()
	if save_err != OK:
		printerr("WARNING: ERROR SAVING PROJECT SETTINGS!")
		printerr("SAVE ERROR: ", save_err)
	add_control_to_dock(EditorPlugin.DOCK_SLOT_RIGHT_BL, panel_scene)

	panel_scene.get_child(3).pressed.connect(switch_to_project_tab)
	add_control_to_container(EditorPlugin.CONTAINER_PROJECT_SETTING_TAB_RIGHT, project_scene)

	add_autoload_singleton("SignalManager", "res://addons/signal_manager/scripts/signal_manager.gd")

func _get_plugin_name():
	return "Signal Manager"

func _exit_tree():

	remove_control_from_docks(panel_scene)
	remove_control_from_container(EditorPlugin.CONTAINER_PROJECT_SETTING_TAB_RIGHT, project_scene)

	panel_scene.call_deferred("queue_free")
	project_scene.call_deferred("queue_free")

	remove_autoload_singleton("SignalManager")

func get_project_tab_index() -> int:
	return project_scene.get_parent().get_tab_idx_from_control(project_scene)

func switch_to_project_tab() -> void:
	project_scene.get_parent().current_tab = get_project_tab_index()


