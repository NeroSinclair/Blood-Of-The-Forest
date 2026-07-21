extends Node2D

# Load adegan zombie yang sudah kamu buat
@onready var zombie_scene = preload("res://Zombie.tscn")

func _ready():
	# Memanggil fungsi spawn 5 zombie saat game dimulai
	for i in range(5):
		spawn_zombie_random()

func spawn_zombie_random():
	var zombie_baru = zombie_scene.instantiate()
	
	# Berdasarkan ukuran map di screenshot (image_35bb1e.png), 
	# batas x sekitar 1150 dan y sekitar 650
	var x_pos = randf_range(100, 1100)
	var y_pos = randf_range(100, 600)
	
	zombie_baru.global_position = Vector2(x_pos, y_pos)
	
	# Tambahkan zombie ke dalam world
	add_child(zombie_baru)
