@tool
class_name URDFImporter
extends EditorImportPlugin

func _get_importer_name():
	return "urdf.importer"

func _get_visible_name():
	return "URDF Importer"

func _get_recognized_extensions():
	return ["urdf"]

func _get_save_extension() -> String:
	return "tscn"

func _get_resource_type() -> String:
	return "PackedScene"

func _import(source: String, save_path: String, options: Dictionary, platform_variants: Array, gen_files: Array) -> Error:
	
	print("Importing URDF file: ", source)
	var urdf_parser = URDFParser.new()
	var root = urdf_parser.parse(source)


# Save the imported scene as a PackedScene resource
	var packed_scene = PackedScene.new()
	packed_scene.pack(root)
	
	print("Root count:", root.get_child_count())
#	for i in root.get_children():
#		print(i)

	
	var p = save_path + "." + _get_save_extension()
	
	var res = ResourceSaver.save(packed_scene, p)
	
	print("URDF Saving:", res)
	
	var r = packed_scene.instantiate()
	
	print(r.get_child_count())
	
	return OK

func _get_import_options(opt: String, preset: int) -> Array[Dictionary]:
	return []

func _get_priority():
	return 1

func _get_import_order():
	return 0
	
func _get_preset_count():
	return 1
	
func _get_preset_name(preset_id: int) -> String:
	return "URFF"
