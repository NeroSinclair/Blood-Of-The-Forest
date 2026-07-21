extends Node2D

@onready var zombie_scene = preload("res://World/Zombie.tscn")
# Mengacu pada file Boss.tscn kamu (pastikan lokasinya benar di res://)
const BOSS_SCENE = preload("res://Boss.tscn") 

# Variabel untuk sistem Kill Count
var jumlah_kill: int = 0
var target_kill: int = 10
var boss_sudah_spawn: bool = false

func _ready():
	# Hentikan Timer Spawn bawaan sejak awal agar tidak ada zombie tambahan yang muncul
	if has_node("SpawnTimer"):
		$SpawnTimer.stop()

	# Hanya spawn 10 zombie saja di awal game
	for i in range(10):
		spawn_zombie_random()
	
	# Koneksi Signal Darah Aris ke UI
	if has_node("Aris") and has_node("CanvasLayer/UIGame"):
		var aris = $Aris
		var ui = $CanvasLayer/UIGame
		if not aris.darah_berubah.is_connected(ui._on_player_darah_berubah):
			aris.darah_berubah.connect(ui._on_player_darah_berubah)
			ui._on_player_darah_berubah(aris.darah)
			
		# === DETEKSI ARIS MATI ===
		if aris.has_signal("mati") and not aris.mati.is_connected(_on_aris_mati):
			aris.mati.connect(_on_aris_mati)
			
		# Inisialisasi damage modifier awal untuk Aris
		aris.set("damage_modifier", 1.0)
		aris.add_to_group("player")

func spawn_zombie_random():
	var spawn_pos = Vector2.ZERO
	var pos_valid = false
	var percobaan = 0
	var maksimal_percobaan = 30 

	while not pos_valid and percobaan < maksimal_percobaan:
		percobaan += 1
		
		# Mengacak posisi zombie (Sesuaikan dengan koordinat map-mu)
		var x_pos = randf_range(-41, 161)
		var y_pos = randf_range(10, 94)
		
		spawn_pos = Vector2(x_pos, y_pos)
		
		if not cek_area_bertabrakan(spawn_pos):
			pos_valid = true

	if pos_valid:
		var zombie_baru = zombie_scene.instantiate()
		
		# 1. Masukkan zombie ke scene tree
		add_child(zombie_baru)
		
		# 2. Atur posisi lokalnya agar akurat di dalam map
		zombie_baru.position = spawn_pos
		
		# 3. Hubungkan sinyal untuk sistem kill count
		if not zombie_baru.is_connected("mati_terkonfirmasi", _on_zombie_mati):
			zombie_baru.mati_terkonfirmasi.connect(_on_zombie_mati)

# Fungsi yang dipanggil setiap kali ada zombie yang mati
func _on_zombie_mati():
	# Jika boss sudah diproses/spawn, abaikan kill zombie yang tersisa
	if boss_sudah_spawn:
		return 
		
	jumlah_kill += 1
	print("Zombie mati! Total kill: ", jumlah_kill)
	
	# Update tampilan angka kill di UI
	if has_node("CanvasLayer/UIGame"):
		$CanvasLayer/UIGame.update_kill_ui(jumlah_kill, target_kill)
	
	# Cek apakah sudah mencapai target 10 zombie untuk memunculkan Boss
	if jumlah_kill >= target_kill:
		kasi_buff_dan_spawn_boss()

func kasi_buff_dan_spawn_boss():
	# Kunci langsung di sini agar fungsi ini tidak dipanggil dua kali saat jeda await
	boss_sudah_spawn = true
	print("10 Zombie kalah! Memberikan Buff dan Memunculkan Boss...")
	
	if has_node("Aris"):
		var aris = $Aris
		
		# 1. Full Heal Darah Aris 
		if "darah" in aris:
			aris.darah = 10
			# PERBAIKAN: Menghilangkan tanda $ ganda agar tidak error
			if has_node("CanvasLayer/UIGame"):
				$CanvasLayer/UIGame._on_player_darah_berubah(aris.darah)
		
		# 2. Buff Damage Aris (Misal jadi 1.5x lipat lebih kuat)
		aris.set("damage_modifier", 1.5)
		print("Aris Full Heal & Buff Damage Aktif!")
	
	# 3. Tunggu 1 detik agar player ada persiapan sebelum Boss muncul
	await get_tree().create_timer(1.0).timeout
	
	# 4. Spawn Boss Utama di posisi SpawnPoint kamu
	if has_node("SpawnPoint"):
		var boss_baru = BOSS_SCENE.instantiate()
		add_child(boss_baru)
		boss_baru.global_position = $SpawnPoint.global_position
		print("BOSS UTAMA TELAH BANGKIT!")
		
		# Hubungkan signal kematian boss (jika boss mati, baru memicu menang)
		if boss_baru.has_signal("tree_exited"):
			boss_baru.tree_exited.connect(menang_game)
			boss_baru.tree_exited.connect(menang_game)

func menang_game():
	print("KAMU MENANG! Boss telah dikalahkan!")
	# Pindah ke scene menang atau munculkan UI kemenangan di sini
	# get_tree().change_scene_to_file("res://Menang.tscn")

func cek_area_bertabrakan(pos: Vector2) -> bool:
	var space_state = get_world_2d().direct_space_state
	var shape_query = PhysicsShapeQueryParameters2D.new()
	var lingkaran = CircleShape2D.new()
	lingkaran.radius = 15.0
	shape_query.shape = lingkaran
	shape_query.transform = Transform2D(0, pos)
	shape_query.collision_mask = 1 
	var result = space_state.intersect_shape(shape_query)
	return result.size() > 0

# Fungsi yang dipanggil saat Aris kehabisan darah / mati
func _on_aris_mati():
	print("Aris telah gugur!")
	get_tree().change_scene_to_file("res://Kalah.tscn")
