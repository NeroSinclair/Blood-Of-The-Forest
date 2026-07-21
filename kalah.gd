extends Control

# Membuat kolom pilihan scene di Inspector secara visual
@export var main_menu_scene: PackedScene

@onready var restart_button = $VBoxContainer/RestartButton
@onready var exit_button = $VBoxContainer/ExitButton

func _ready():
	# Sembunyikan UI Kalah saat game pertama kali dimulai
	hide()
	
	# Menghubungkan tombol secara otomatis lewat kode
	restart_button.pressed.connect(_on_restart_button_pressed)
	exit_button.pressed.connect(_on_exit_button_pressed)

# Fungsi ini dipanggil dari script Player saat mati
func munculkan_layar_kalah():
	show()
	get_tree().paused = true # Hentikan pergerakan game di background

func _on_restart_button_pressed():
	get_tree().paused = false # Normalkan kembali waktu game sebelum reload
	
	# Menggunakan reload_current_scene agar otomatis mengulang scene yang sedang berjalan
	var error_code = get_tree().reload_current_scene()
	if error_code != OK:
		print("Gagal mereload scene! Kode Error: ", error_code)

func _on_exit_button_pressed():
	get_tree().paused = false # Wajib di-unpause dulu sebelum pindah scene!
	
	# Cek apakah scene Main Menu sudah dimasukkan di Inspector
	if main_menu_scene:
		get_tree().change_scene_to_packed(main_menu_scene)
	else:
		# Jika lupa pasang di Inspector, dia akan close game selaku fail-safe
		print("Scene Main Menu belum dimasukkan di Inspector!")
		get_tree().quit()
