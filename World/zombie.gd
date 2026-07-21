extends CharacterBody2D

signal mati_terkonfirmasi

@onready var sprite = $AnimatedSprite2D
@onready var stats = $Stats # Asumsi kamu punya node Stats untuk HP zombie
@onready var hitbox := $Hitbox  # Ini Area2D buat nerima serangan Aris

@export var kecepatan = 70.0
@export var jarak_serang = 40.0
@export var waktu_patroli = 2.0
var arah_patroli = Vector2.RIGHT
var timer_patroli = 0.0

var target_player = null
var sudah_mati : bool = false
var health : int = 3

# 1. TAMBAHKAN VARIABEL PENGUNCI SERANGAN DI SINI
var sedang_serang : bool = false

func _ready():
	sprite.play("idle")
	
	# Tambahkan Zombie ke group agar Aris bisa mengenali ini sebagai musuh
	add_to_group("musuh")
	
	# Pastikan Hitbox zombie punya group agar Aris tahu ini yang kasih damage
	if has_node("Hitbox"):
		$Hitbox.add_to_group("zombie_hitbox")
	
	# Koneksi signal hitbox untuk menerima serangan dari AtkBox Aris
	hitbox.area_entered.connect(kena_serang)
	
	# Koneksi signal deteksi player secara otomatis
	if has_node("DetectionArea"):
		$DetectionArea.body_entered.connect(_on_detection_body_entered)
		$DetectionArea.body_exited.connect(_on_detection_body_exited)

func _physics_process(delta):
	# Jika mati atau sedang menyerang, hentikan semua kalkulasi pergerakan/patroli
	if sudah_mati or sedang_serang:
		return
		
	if target_player:
		var jarak = global_position.distance_to(target_player.global_position)
		var arah = (target_player.global_position - global_position).normalized()
		
		if jarak <= jarak_serang:
			# State: Serang (Panggil fungsi serang baru yang pakai pengunci)
			velocity = Vector2.ZERO
			eksekusi_serang(arah)
		else:
			# State: Kejar (Chasing)
			velocity = arah * kecepatan
			pilih_animasi_jalan(arah)
	else:
		# State: Patroli (Wandering)
		timer_patroli -= delta
		if timer_patroli <= 0:
			# Acak arah baru secara random
			arah_patroli = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized()
			timer_patroli = waktu_patroli
		
		velocity = arah_patroli * (kecepatan * 0.5)
		pilih_animasi_jalan(arah_patroli)
		
	move_and_slide()

func pilih_animasi_jalan(arah: Vector2):
	if arah == Vector2.ZERO:
		pilih_animasi_idle(arah)
		return

	# Cek apakah gerakan lebih dominan Horizontal (Kanan/Kiri) atau Vertikal (Atas/Bawah)
	if abs(arah.x) > abs(arah.y):
		# Gerak Kanan / Kiri
		sprite.play("Jalan_kanan")
		sprite.flip_h = arah.x < 0 # Flip ke kiri jika nilai x negatif
	else:
		# Gerak Vertikal
		sprite.flip_h = false # Reset flip horizontal saat bergerak vertikal
		if arah.y > 0:
			sprite.play("Jalan_bawah")
		else:
			sprite.play("Jalan_atas")

# Fungsi saat zombie dalam posisi diam (idle) tapi menghadap arah terakhir
func pilih_animasi_idle(arah: Vector2):
	if abs(arah.x) > abs(arah.y):
		sprite.play("idle_kanan")
		sprite.flip_h = arah.x < 0
	else:
		sprite.flip_h = false
		if arah.y > 0:
			sprite.play("idle_bawah")
		else:
			sprite.play("idle_atas")

# 2. FUNGSI BARU: Mengunci state dan menunggu animasi selesai
func eksekusi_serang(arah: Vector2):
	sedang_serang = true
	velocity = Vector2.ZERO
	
	# Mainkan animasi serang sesuai arah
	pilih_animasi_serang(arah)
	
	# Tunggu sampai animasi serangan selesai diputar penuh
	await sprite.animation_finished
	
	# Jika target masih ada di dekat zombie setelah tebasan selesai, kurangi HP player di sini
	# (Misal: target_player.terima_damage(1))
	
	# Beri sedikit jeda/cooldown serang (opsional, misal 0.5 detik) sebelum bisa jalan/nyerang lagi
	await get_tree().create_timer(0.5).timeout
	
	sedang_serang = false

# Fungsi menentukan animasi serang (atas, bawah, samping)
func pilih_animasi_serang(arah: Vector2):
	if abs(arah.x) > abs(arah.y):
		sprite.play("serang_kanan")
		sprite.flip_h = arah.x < 0
	else:
		if arah.y > 0:
			sprite.play("serang_bawah")
		else:
			sprite.play("serang_atas")

# Signal Deteksi Player
func _on_detection_body_entered(body):
	if body.is_in_group("Aris"):
		target_player = body

func _on_detection_body_exited(body):
	if body == target_player:
		target_player = null

# Sistem Menerima Damage (Saat kena hit Aris)
func kena_serang(area):
	if sudah_mati: return
	
	# Gunakan Group "player_atk" agar lebih akurat dibanding cek nama node
	if area.is_in_group("player_atk") or area.name == "AtkBox":
		health -= 1
		# Efek flicker merah saat terkena serangan
		var tween = create_tween()
		tween.tween_property(sprite, "modulate", Color.RED, 0.1)
		tween.tween_property(sprite, "modulate", Color.WHITE, 0.1)
		
		if health <= 0:
			musuh_mati()

# Fungsi saat Zombie mati
func musuh_mati():
	sudah_mati = true
	velocity = Vector2.ZERO
	hitbox.set_deferred("monitoring", false)
	sprite.play("mati")
	await sprite.animation_finished
	mati_terkonfirmasi.emit()
	queue_free()

func _on_stats_no_health():
	musuh_mati()
