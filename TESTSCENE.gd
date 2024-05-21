@tool
extends Control

@export var proper: DynamicProperty:
	set(value):
		if value:
			proper = value
			#if proper is DynamicProperty: proper.setup(self)
			#print(self.get_class())
			#print(self.get_script().get_instance_base_type())
			#print(self.get_script().get_base_script())
			#print(ProjectSettings.get_global_class_list().map(func(a): if a.path == self.get_script().resource_path: return a.class))
			#print(self.get_property_list())
			#print(value.usage)
		else:
			proper = value
