@tool
class_name URDFImporter
extends EditorImportPlugin

func _get_importer_name():
	return "urdf.importer"

func _get_visible_name():
	return "URDF Importer"

func _get_recognized_extensions():
	return ["urdf"]

func _get_save_extension():
	return "tres"

func _get_resource_type():
	return "URDFResource"

func _import(source_file, save_path, options, platform_variants, gen_files):
	# Read and parse the URDF file
	# Convert the URDF data into a URDFResource instance
	# Save the URDFResource instance to a .tres file
	pass
