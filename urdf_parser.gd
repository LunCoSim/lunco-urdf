class_name URDFParser

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
		if parser.get_node_type() == XMLParser.NODE_ELEMENT:
			var element = parser.get_node_name()
			if element == "link":
				# Handle the link element
				print("link")
				var name = parser.get_named_attribute_value("name")
				
				var link_node = create_link_node(name)
				root.add_child(link_node)
				link_node.owner = root
				
			elif element == "joint":
				# Handle the joint element
				print("joint")
				pass
	
	return root
	

func pack(root):
	var packed_scene = PackedScene.new()
	
	var result = packed_scene.pack(root)
	print("Pack result: ", result)
	return packed_scene
	
func create_link_node(link_data):
	var link_node = Node3D.new()
	link_node.name = link_data
	# Set the link_node properties based on link_data
	return link_node
	
func create_joint_node(joint_data):
	var joint_node = Generic6DOFJoint3D.new()
	# Set the joint_node properties based on joint_data
	return joint_node
