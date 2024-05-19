@tool
extends Button

func _show_project_settings():
	#for item in get_tree().root.get_child(0).get_child(4).get_child(6).get_method_list().map(func(a): return a.name):
	#	print(item)
	#var saved_size: Rect2 = EditorInterface.get_editor_settings().get_project_metadata("dialog_bounds", "project_settings", Rect2())
	#need to finish importing code from popup_project_settings for fully correct launch, currently broken.
	#if saved_size != Rect2():
	#	get_tree().root.get_child(0).get_child(4).get_child(6).popup(saved_size);
	#else:
	#	get_tree().root.get_child(0).get_child(4).get_child(6).popup_centered_clamped(Vector2(900, 700) * EditorInterface.get_editor_scale(), 0.8);
	get_tree().root.get_child(0).get_child(4).get_child(0).get_child(0).get_child(0).get_child(1).id_pressed.emit(36)
