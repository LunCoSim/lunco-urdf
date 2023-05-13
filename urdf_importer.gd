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
	# Parse the URDF file using XMLParser
	var parser = XMLParser.new()
	var err = parser.open(source)
	
	if err != OK:
		printerr("Failed to open URDF file: %s" % source)
		return ERR_CANT_OPEN
	
	# Create the root node for the imported scene
	var root = Node3D.new()
	
	# Parse the URDF file and generate the scene hierarchy
	while parser.read() == OK:
		if parser.node_type == XMLParser.NODE_ELEMENT:
			var element = parser.node_name
			if element == "link":
				# Handle the link element
				pass
			elif element == "joint":
				# Handle the joint element
				pass
	
	# Save the imported scene as a PackedScene resource
	var packed_scene = PackedScene.new()
	packed_scene.pack(root)
	ResourceSaver.save(packed_scene, save_path)
	
	return OK



func _get_import_options(opt: String, preset: int) -> Array[Dictionary]:
	return []
