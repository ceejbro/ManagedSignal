@tool
extends Node

var global_signal_list: GlobalSignalList = preload("res://addons/signal_manager/resources/primary_global_signal_list.tres")

var global_signals = global_signal_list.global_signals

func _ready():
	for signal_name in global_signals:
		#User signals cannot be accessed by 'index' (i.e. Node_name.signal_name)
		add_user_signal(signal_name)

func _get(property):
	if global_signals.has(property):
		return Signal(self, property)

func _get_property_list():
	var properties = []
	for signal_name in global_signals:
		properties.append(
			{
				"name": signal_name,
				"type": TYPE_SIGNAL,
				"usage": PROPERTY_USAGE_NO_EDITOR,
			}
		)
	notify_property_list_changed()
	return properties
