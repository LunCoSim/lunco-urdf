extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	var parser = URDFParser.new()
	
	var source = "res://addons/nasa/m2020-urdf-models/rover/m2020.urdf"
	var save_path = "res://.godot/import/m2020.urdf-b5659053f27965e078f815cac6270e1b"
	
	save_path = "res://out"
	
	
	var root = parser.parse(source)
	var packed_scene = parser.pack(root)
	
	print(packed_scene)
	
	
	var p = save_path + "_test.tscn"
	print("Save path:", p)
	print("Root child count:", root.get_child_count())
		
	var res = ResourceSaver.save(packed_scene, p)
	
	print("Saving packed scene result: ", res)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
