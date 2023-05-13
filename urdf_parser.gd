# Parser of URDF files to Scene

class_name URDFParser
extends Resource

func parse(source: String) -> Node3D:
	var parser = XMLParser.new()
	var err = parser.open(source)
	
	if err != OK:
		printerr("Failed to open URDF file: %s" % source)
		return
#		return ERR_CANT_OPEN //TODO: handle open error correctly
	
	# Create the root node for the imported scene
	var root = Node3D.new()
	
	# Parse the URDF file and generate the scene hierarchy
	while parser.read() == OK:
		match parser.get_node_type():
			XMLParser.NODE_ELEMENT_END:
				print("element_end")
			XMLParser.NODE_ELEMENT:
				var element = parser.get_node_name()
				
				match element:
					"link":
						link(parser, root)
					"joint":
						joint()
					"robot":
						robot(parser, root)
					"visual":
						visual(parser, root)
					"mesh":
						mesh(parser, root, source)
					_:
						print("Unknown element: ", element)
	
	return root
	

func pack(root):
	var packed_scene = PackedScene.new()
	
	var result = packed_scene.pack(root)
	print("Pack result: ", result)
	return packed_scene

# --------------

func create_link_node(link_data):
	var link_node = Node3D.new()
	link_node.name = link_data
	# Set the link_node properties based on link_data
	return link_node
	
func create_joint_node(joint_data):
	var joint_node = Generic6DOFJoint3D.new()
	# Set the joint_node properties based on joint_data
	return joint_node
	
#------------

func robot(parser, root):
	root.name = parser.get_named_attribute_value("name")
	
func link(parser, root):
	# Handle the link element
	#	print("link")
	
	var name = parser.get_named_attribute_value("name")
	
	var link_node = create_link_node(name)
	root.add_child(link_node)
	link_node.owner = root
	
func joint():
	pass

#--
func inertial():
	pass
	
func origin():
	pass
	
func mass():
	pass
	
func inertia():
	pass

#---	
func visual(parser, root):
	pass
#	var count = root.get_child_count()
#	var parent = root.get_child(count-1)
#
#	var visual = Node3D.new()
#
#	parent.add_child(visual)
#	visual.owner = root

func _origin():
	pass
	
func geometry():
	pass


		
func mesh(parser, root, source):
	var filename = parser.get_named_attribute_value("filename")
	
	
		
	var p = source.get_base_dir() + "/" + filename.right(filename.length()-2)
	
	print("source path: ", source)
	print("filename path: ", filename)
	print("res path: ", p)
	
	var res = load(p)
	print("Res result: ", res)
	
	var mesh = res.instantiate()
#					mesh.load
	print("Mesh filename: ", filename)
	
	
	var count = root.get_child_count()
	var parent = root.get_child(count-1)
	
	
	parent.add_child(mesh)
	mesh.owner = root
	
#------

func parent():
	pass
	
func child():
	pass
