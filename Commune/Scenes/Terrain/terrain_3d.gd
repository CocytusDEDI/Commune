extends Terrain3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var noise := FastNoiseLite.new()
	noise.frequency = 0.0005
	var img: Image = Image.create(2048, 2048, false, Image.FORMAT_RF)
	for x in 2048:
		for y in 2048:
			img.set_pixel(x, y, Color(noise.get_noise_2d(x, y)*0.5, 0., 0., 1.))
	self.storage.import_images([img, null, null], Vector3(-1024, 0, -1024), 0.0, 300.0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
