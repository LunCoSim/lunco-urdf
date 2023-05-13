@tool
extends EditorPlugin

var urdf_importer = URDFImporter.new()

func _enter_tree():
	add_import_plugin(urdf_importer)

func _exit_tree():
	remove_import_plugin(urdf_importer)
