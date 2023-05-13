# Parser of URDF files to Scene

class_name URDFParser
extends Resource

var source_path = ""
var owner = null

func parse(_source_path: String) -> Node3D:
	source_path = _source_path
	
	var parser = XML.new()
	var doc: XMLDocument = parser.parse_file(source_path)
	var root = Node3D.new()
	
	owner = root
	
	if not doc:
		printerr("Failed to open URDF file: %s" % source_path)
		return
	
	process_node(doc.root, root)

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
func get_child_by_name(node: XMLNode, name: String, recursive:=false):
	if not recursive:
		for child in node.children:
			if child.name == name:
				return child
				
func process_node(node, root):
	
	match node.name:
		"robot":
			return robot(node, root)
		"link":
			return link(node, root)
		"joint":
			return joint(node, root)
		"visual":
			return visual(node, root)
		"mesh":
			mesh(node, root)
		_:
			print("Unknown XMLNode element: ", node.name)
			
	
#------------

func robot(node: XMLNode, root: Node3D):
	root.name = node.attributes["name"]
	
	for i in node.children:
		process_node(i, root)
#	root.name = parser.get_named_attribute_value("name")
	
func link(node: XMLNode, root: Node3D):
	# Handle the link element
	
	var name = node.attributes["name"]
	print("link: ", name)
	
	var link_node = create_link_node(name)
	root.add_child(link_node)
	link_node.owner = owner

	var visual_node = get_child_by_name(node, "visual")
	print("visual_node: ", visual_node)
	
	if visual_node:
		var geometry_node = get_child_by_name(visual_node, "geometry")
		
		if geometry_node:
			var mesh_node = get_child_by_name(geometry_node, "mesh")
			if mesh_node:
				mesh(mesh_node, link_node)
			
	
func joint(node: XMLNode, root: Node3D):
	
	var joint_type = node.attributes.get("type")
	var name = node.attributes["name"]
	
	var joint = Generic6DOFJoint3D.new()
	
	
# origin, parent, child
#
#	joint.node_a = get_child_by_name(node, "")
#	joint.node_b = get_child_by_name(root, "")
#
	match joint_type:
		"prismatic":
			pass
		"revolute":
			pass
		"fixed":
			pass
		"floating":
			pass
		_:
			print("Unknown joint type: ", joint_type)

#--
func inertial(node: XMLNode, root: Node3D):
	pass
	
func origin(node: XMLNode, root: Node3D):
	pass
	
func mass(node: XMLNode, root: Node3D):
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


		
func mesh(node, root):
	print("mesh")
	var filename = node.attributes["filename"]
	
	var p = source_path.get_base_dir() + "/" + filename.right(filename.length()-2)
	
	print("source path: ", source_path)
	print("filename path: ", filename)
	print("res path: ", p)
	print("Mesh filename: ", filename)
	
	var res = load(p)
	print("Res result: ", res)
	
	var mesh = res.instantiate()
#					mesh.load
	root.add_child(mesh)
	mesh.owner = owner
	
#------

func parent():
	pass
	
func child():
	pass
