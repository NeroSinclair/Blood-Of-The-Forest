extends Node2D

# Load file tscn musuh kamu (sesuaikan path-nya jika berbeda)
@export var keroco_scene: PackedScene = preload("res://World/Zombie.tscn")
@export var boss_scene: PackedScene = preload("res://Boss.tscn")

# Posisi spawn musuh (bisa kamu sesuaikan dengan posisi di map kamu)
@export var spawn_position: Vector2 = Vector2(500, 300)

# State untuk melacak ronde aktif
enum WaveState { KEROCO, BOSS }
var current_state = WaveState.BOSS # Mulai langsung dari Boss sesuai skenariomu

func _ready() -> void:
	# Mulai game dengan memunculkan Boss pertama
	spawn_boss()

func _process(_delta: float) -> void:
	# Cek jumlah musuh yang masih hidup di dalam Group "musuh"
	var jumlah_musuh_hidup = get_tree().get_nodes_in_group("musuh").size()
	
	# Jika musuh di wave ini sudah habis (0)
	if jumlah_musuh_hidup == 0:
		handle_wave_cleared()

func handle_wave_cleared() -> void:
	# Jika baru saja mengalahkan Boss, ganti ke wave 10 keroco
	if current_state == WaveState.BOSS:
		current_state = WaveState.KEROCO
		print("Boss kalah! Memunculkan 10 keroco...")
		spawn_keroco(10)
		
	# Jika baru saja mengalahkan semua keroco, balik lagi memunculkan Boss
	elif current_state == WaveState.KEROCO:
		current_state = WaveState.BOSS
		print("10 Keroco kalah! Boss muncul kembali...")
		spawn_boss()

func spawn_boss() -> void:
	var boss_instance = boss_scene.instantiate()
	boss_instance.global_position = spawn_position
	
	# PENTING: Masukkan ke tree utama agar process() bisa menghitungnya di dalam group
	get_parent().add_child.call_deferred(boss_instance)

func spawn_keroco(jumlah: int) -> void:
	for i in range(jumlah):
		var keroco_instance = keroco_scene.instantiate()
		
		# Beri sedikit variasi posisi spawn acak disekitar titik agar tidak menumpuk di satu tempat
		var acak_posisi = Vector2(randf_range(-100, 100), randf_range(-100, 100))
		keroco_instance.global_position = spawn_position + acak_posisi
		
		get_parent().add_child.call_deferred(keroco_instance)
