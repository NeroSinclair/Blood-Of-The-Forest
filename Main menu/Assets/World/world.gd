extends Node2D

@onready var zombie_scene = preload("res://Zombie.tscn")

func _ready():
	for i in range(10):
		spawn_zombie_random()

func spawn_zombie_random():
	var spawn_pos = Vector2.ZERO
	var pos_valid = false
	var percobaan = 0
	var maksimal_percobaan = 30 # Ditambah agar lebih gigih mencari tempat kosong

	while not pos_valid and percobaan < maksimal_percobaan:
		percobaan += 1
		var x_pos = randf_range(100, 1100)
		var y_pos = randf_range(100, 600)
		spawn_pos = Vector2(x_pos, y_pos)
		
		# Sekarang mengecek AREA, bukan cuma titik
		if not cek_area_bertabrakan(spawn_pos):
			pos_valid = true

	if pos_valid:
		var zombie_baru = zombie_scene.instantiate()
		zombie_baru.global_position = spawn_pos
		add_child(zombie_baru)

# Fungsi baru untuk mengecek apakah seluruh badan zombie muat di posisi tersebut
func cek_area_bertabrakan(pos: Vector2) -> bool:
	var space_state = get_world_2d().direct_space_state
	
	# Membuat bentuk lingkaran bayangan seukuran badan zombie (radius 15 pixel)
	var shape_query = PhysicsShapeQueryParameters2D.new()
	var lingkaran = CircleShape2D.new()
	lingkaran.radius = 15.0 # Sesuaikan dengan lebar badan zombie kamu
	
	shape_query.shape = lingkaran
	shape_query.transform = Transform2D(0, pos)
	
	# Mengecek Layer 1 (biasanya tempat pohon, batu, dan pagar)
	shape_query.collision_mask = 1 
	
	var result = space_state.intersect_shape(shape_query)
	return result.size() > 0
