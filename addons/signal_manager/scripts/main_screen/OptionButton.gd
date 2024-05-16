@tool
extends OptionButton

var primary_list = load("res://addons/signal_manager/resources/primary_global_signal_list.tres")
var id_to_text: Array[String]

# Called when the node enters the scene tree for the first time.
func _ready():
	clear()
	primary_list.global_signals.sort_custom(func(a,b): return a.naturalcasecmp_to(b) < 0)
	for signal_name in primary_list.global_signals:
		add_item(signal_name)
		id_to_text.append(signal_name)
