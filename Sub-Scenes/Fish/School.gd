tool
extends MultiMeshInstance

export(float, 1.0, 25.0) var velocity: float = 5.0
export(float, 0.0, 100.0) var margin: float = 5.0
export(float, 0.0, 100.0) var layer_margin: float = 5.0
export(int, 1, 10) var sphere_layers: int = 3
export var reset: bool = false

var goldenRatio: float = (1 + sqrt(5)) / 2
var angle: float = 2 * PI * goldenRatio

func _ready() -> void:
	distribute()
	randomize_animation()

func _process(delta: float) -> void:
	distribute()
	if reset:
		reset = false
		distribute()
		randomize_animation()
	pass

func _physics_process(delta: float) -> void:
	(self as GeometryInstance).material_override.set_shader_param("time_scale", clamp(velocity, 1.0, 25.0))

func randomize_animation() -> void:
	var count: int = self.multimesh.instance_count
	for i in range(count):
		(self as MultiMeshInstance).multimesh.set_instance_custom_data(i, Color(randf(), randf(), randf(), randf()))

func distribute() -> void:
	uniformSphericalPointDistribution()







func uniformSphericalPointDistribution() -> void:
	var count: int = self.multimesh.instance_count

	var alotments: int = 0

	for i in range(1, sphere_layers + 1):
		alotments += i

	var count_per_alotment: int = int(floor(float(count) / float(alotments)))

	print("    sphere_layers: " + str(sphere_layers) + " count: " + str(count))
	print("    alotments: " + str(alotments) + " count_per_alotment: " + str(count_per_alotment))

	var last_index = 0

	for layer_i in range(0, (sphere_layers)):
		var layer: int = layer_i + 1
		var current_layer_count: int = layer * count_per_alotment

		var start: int = last_index
		var end: int = start + current_layer_count

		if (layer == sphere_layers):
			end = count

		print("    layer:" + str(layer) + " start: " + str(start) + " end: " + str(end) + " current_layer_count: " + str(current_layer_count))

		for i in range(start, end):

			var zero_index: int = i - start;

			var t: float = float(i - start) / float(end - start)
			var inclination: float = acos(1.0 - (2.0 * t))
			var azimuth: float = angle * zero_index

			var x: float = sin(inclination) * cos(azimuth)
			var y: float = sin(inclination) * sin(azimuth)
			var z: float = cos(inclination)

			var pos: Vector3 = Vector3(x, y, z) * (margin + (layer_margin * layer))

			#print("i= " + str(i) + " zero_index= " + str(zero_index) + " t= " + str(t) + " inclination= " + str(inclination) + " azimuth= " + str(azimuth) + " pos= " + str(pos))

			var position: Transform = Transform()
			position = position.translated(pos)
			#print(pos)
			(self as MultiMeshInstance).multimesh.set_instance_transform(i, position)
			last_index = i









func uniformBulletOrderedPointDistribution() -> void:

	var count: int = self.multimesh.instance_count

	var alotments: int = 0;

	for i in range(1, sphere_layers):
		alotments += i;

	var count_per_alotment: int = count / alotments

	for layer in range(1, sphere_layers):
		for i in range( int((layer - 1) * count_per_alotment), int(layer * count_per_alotment) ):

			var t: float = float(i) / float( (layer * count_per_alotment) )
			var inclination: float = acos(1.0 - (2.0 * t))
			var azimuth: float = angle * (i - int((layer - 1) * count_per_alotment))

			var x: float = sin(inclination) * cos(azimuth)
			var y: float = sin(inclination) * sin(azimuth)
			var z: float = cos(inclination)
			var pos: Vector3 = Vector3(x, y, z) * (margin * layer)

			var position: Transform = Transform()
			position = position.translated(pos)
			(self as MultiMeshInstance).multimesh.set_instance_transform(i, position)


func uniformBulletChaoticPointDistribution() -> void:

	var count: int = self.multimesh.instance_count

	var alotments: int = 0;

	for i in range(1, sphere_layers):
		alotments += i;

	var count_per_alotment: int = count / alotments

	for layer in range(1, sphere_layers):
		for i in range( int((layer - 1) * count_per_alotment), int(layer * count_per_alotment) ):

			var t: float = float(i) / float( (layer * count_per_alotment) )
			var inclination: float = acos(1.0 - (2.0 * t))
			var azimuth: float = angle * i

			var x: float = sin(inclination) * cos(azimuth)
			var y: float = sin(inclination) * sin(azimuth)
			var z: float = cos(inclination)
			var pos: Vector3 = Vector3(x, y, z) * (margin * layer)

			var position: Transform = Transform()
			position = position.translated(pos)
			(self as MultiMeshInstance).multimesh.set_instance_transform(i, position)
