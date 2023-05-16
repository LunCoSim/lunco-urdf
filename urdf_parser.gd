# Parser of URDF files to Scene

class_name URDFParser
extends Resource

var source_path = ""
var owner = null


var materials = {}

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
	var link_node = RigidBody3D.new()
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
		"material":
			material(node, root)
		_:
			print("Unknown XMLNode element: ", node.name)
			
	
#------------

func robot(node: XMLNode, root: Node3D):
	root.name = node.attributes["name"]
	
	for i in node.children:
		process_node(i, root)
	
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
			
			var mesh_node :XMLNode = geometry_node.children[0]
			
			match mesh_node.name:
				"mesh":
					mesh(mesh_node, link_node)
				"cylinder":
					cylinder(mesh_node, link_node)
				"box":
					box(mesh_node, link_node)
				_:
					print("Unknown geometry: ", mesh_node.name)
					
		var origin_node = get_child_by_name(visual_node, "origin")
		
		if origin_node:
			var xyz = origin_node.attributes["xyz"].split(" ")
			var rpy = origin_node.attributes["rpy"].split(" ")
			
			var x = float(xyz[0])
			var y = float(xyz[1])
			var z = float(xyz[2])
			
			link_node.position = Vector3(x, y, z)
			
		var material_node = get_child_by_name(visual_node, "material")
		
		if material_node:
			for chld in link_node.get_children():
				if chld is MeshInstance3D:
					chld.material_override = materials[material_node.name]
	
func joint(node: XMLNode, root: Node3D):
	
	var joint_type = node.attributes.get("type")
	var name = node.attributes["name"]
	
	var joint = Generic6DOFJoint3D.new()
	
	
	var parent = get_child_by_name(node, "parent")
	var child = get_child_by_name(node, "child")
	
	var parent_name = parent.attributes["link"]
	var child_name = child.attributes["link"]
	
	var parent_node = root.get_node(parent_name)
	var child_node = root.get_node(child_name)
	
	
	match joint_type:
		"prismatic":
			pass
		"revolute":
			pass
		"fixed":
			print("fixed joint")
			# Hack to move to parent from chiled CollisionShape3D due to limitations of Godot
			# TBD: File proposal to add fixed Joint3D
#			joint = HingeJoint3D.new()
			for chld in child_node.get_children():
				if chld is CollisionShape3D:
					chld.reparent(parent_node)
		"floating":
			pass
		_:
			print("Unknown joint type: ", joint_type)
	
	
	
	joint.node_a = "../"+parent_name
	joint.node_b = "../"+child_name
	
#	print("asdasd: ", root.get_node(parent_name).get_path())
##	joint.node_a = NodePath(parent_name)
#	joint.node_a = root.get_node(parent_name).get_path()
#	joint.node_b = root.get_node(child_name).get_path()

	root.add_child(joint)
	joint.owner = owner

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


# ----------

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

func cylinder(node, root):
	var mesh_instance = MeshInstance3D.new()
	
	var mesh = CylinderMesh.new()
	
	var length = float(node.attributes["length"])
	var radius = float(node.attributes["radius"])
					
	mesh.height = length
	mesh.bottom_radius = radius
	mesh.top_radius = radius
#					mesh.load
	mesh_instance.mesh = mesh
	
	var collision_shape = CollisionShape3D.new()
	collision_shape.shape = mesh.create_convex_shape()
	
	root.add_child(collision_shape)
	root.add_child(mesh_instance)
	
	collision_shape.owner = owner
	mesh_instance.owner = owner
	

func box(node, root):
	
	var mesh_instance = MeshInstance3D.new()
	
	var mesh = BoxMesh.new()
	
					
	var size_array = String(node.attributes["size"]).split(" ")
	
	var x = float(size_array[0])
	var y = float(size_array[1])
	var z = float(size_array[2])
	
	mesh.size.x = x
	mesh.size.y = y
	mesh.size.z = z
#					mesh.load
	mesh_instance.mesh = mesh
	
	var collision_shape = CollisionShape3D.new()
	collision_shape.shape = mesh.create_convex_shape()
	
	root.add_child(collision_shape)
	root.add_child(mesh_instance)
	
	collision_shape.owner = owner
	mesh_instance.owner = owner
	
	
#------
func material(node: XMLNode, root):
	var mat = StandardMaterial3D.new()
	
	var color_node = get_child_by_name(node, "color")
	
	var color_rgba = color_node.attributes["rgba"].split(" ")
	
	var r = float(color_rgba[0])
	var g = float(color_rgba[1])
	var b = float(color_rgba[2])
	var a = float(color_rgba[3])
	
	mat.albedo_color = Color(r, g, b, a)
	
	var name = node.name
	materials[name] = mat

#------
func parent():
	pass
	
func child():
	pass
