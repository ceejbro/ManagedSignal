@tool
extends Button

# Called when the node enters the scene tree for the first time.
func _ready():
	pressed.connect(_copy_to_clip)

func _copy_to_clip():
	EditorInterface.get_script_editor().get_current_editor().get_base_editor()
	#DisplayServer.clipboard_set(text)
