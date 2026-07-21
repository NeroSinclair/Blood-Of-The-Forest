extends CharacterBody2D

# Pengaturan dasar Boss
@export var speed: float = 60.0
@export var max_health: int = 200
var current_health: int = max_health

# Status Boss
var player: Node2D = null
var bisa_serang: bool = true
var sedang_serang: bool = false

# Menyimpan arah terakhir ("kanan", "atas", "bawah") untuk animasi idle & serang
var arah_terakhir: String = "kanan"

# Referensi ke Node Anak
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var detection_area: Area2D = $DetectionArea
@onready var attack_area: Area2D = $AttackArea
@onready var hurtbox: Area2D = $Hurtbox

func _ready() -> void:
	current_health = max_health
	
	# Hubungkan signal otomatis lewat kode
	detection_area.body_entered.connect(_on_detection_area_body_entered)
	detection_area.body_exited.connect(_on_detection_area_body_exited)
	attack_area.body_entered.connect(_on_attack_area_body_entered)
	attack_area.body_exited.connect(_on_attack_area_body_exited)
	hurtbox.area_entered.connect(_on_hurtbox_area_entered)
	
	animated_sprite.play("idle_kanan")

func _physics_process(_delta: float) -> void:
	# Jika sedang memutar animasi mati atau serang, jangan mengejar
	if sedang_serang or current_health <= 0:
		return
		
	if player:
		var direction = global_position.direction_to(player.global_position)
		velocity = direction * speed
		
		atur_animasi_jalan(direction)
		move_and_slide()
	else:
		velocity = Vector2.ZERO
		# Memainkan animasi idle sesuai arah terakhir menghadap sebelum berhenti
		animated_sprite.play("idle_" + arah_terakhir)

func atur_animasi_jalan(direction: Vector2) -> void:
	# Flip sprite horizontal secara otomatis jika bergerak ke kiri (menggunakan setelan kanan)
	if direction.x > 0:
		animated_sprite.flip_h = false
	elif direction.x < 0:
		animated_sprite.flip_h = true
		
	# Tentukan animasi berdasarkan sumbu dominan (X atau Y)
	if abs(direction.x) > abs(direction.y):
		animated_sprite.play("jalan_kanan")
		arah_terakhir = "kanan"
	else:
		if direction.y > 0:
			animated_sprite.play("jalan_bawah")
			arah_terakhir = "bawah"
		else:
			animated_sprite.play("jalan_atas")
			arah_terakhir = "atas"

# =================== LOGIKA DETEKSI & PERGERAKAN ===================

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.name == "Player" or body.is_in_group("player"):
		player = body

func _on_detection_area_body_exited(body: Node2D) -> void:
	if body == player:
		player = null

# =================== LOGIKA MENYERANG PLAYER ===================

func _on_attack_area_body_entered(body: Node2D) -> void:
	if (body.name == "Player" or body.is_in_group("player")) and bisa_serang:
		serang_player()

func _on_attack_area_body_exited(body: Node2D) -> void:
	if body == player:
		pass

func serang_player():
	sedang_serang = true
	bisa_serang = false
	velocity = Vector2.ZERO
	
	# MENYESUAIKAN SPRITEFRAMES: Memainkan animasi serang sesuai arah hadap (serang_kanan / serang_atas / serang_bawah)
	animated_sprite.play("serang_" + arah_terakhir) 
	
	# Tunggu sampai animasi serang selesai
	await animated_sprite.animation_finished
	
	# Jika player masih menempel di area serang setelah animasi selesai, beri damage ke player
	if attack_area.has_overlapping_bodies():
		for body in attack_area.get_overlapping_bodies():
			if body.has_method("terima_damage"):
				body.terima_damage(2) # Boss memberi damage sebesar 2 ke player
				
	sedang_serang = false
	
	# Cooldown serangan boss (menunggu 1.5 detik sebelum bisa mukul lagi)
	await get_tree().create_timer(1.5).timeout
	bisa_serang = true
	
	# Cek lagi jika player masih di dekat boss setelah cooldown, serang lagi
	if attack_area.has_overlapping_bodies() and player:
		serang_player()

# =================== LOGIKA TERKENA PUKULAN PLAYER ===================

func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.name == "AtkBox":
		take_damage(25) # Setiap tebasan player mengurangi 25 HP boss

func take_damage(amount: int) -> void:
	current_health -= amount
	print("HP Boss: ", current_health)
	
	var tween = create_tween()
	tween.tween_property(animated_sprite, "modulate", Color.RED, 0.1)
	tween.tween_property(animated_sprite, "modulate", Color.WHITE, 0.1)
	
	if current_health <= 0:
		mati()

func mati():
	set_physics_process(false)
	sedang_serang = false
	animated_sprite.play("mati")
	await animated_sprite.animation_finished
	queue_free() # Menghapus boss dari scene (mati)
