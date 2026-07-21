extends Control

# Membuka opsi di Inspector untuk memilih scene Main Menu secara visual
@export var main_menu_scene: PackedScene

@onready var resume_button = $VBoxContainer/ResumeButton
@onready var restart_button = $VBoxContainer/RestartButton
@onready var help_button = $VBoxContainer/HelpButton
@onready var exit_button = $VBoxContainer/ExitButton
@onready var help_node = $Help

func _ready():
	hide()
	
	# Hubungkan signal tombol
	resume_button.pressed.connect(_on_resume_pressed)
	restart_button.pressed.connect(_on_restart_pressed)
	help_button.pressed.connect(_on_help_pressed)
	exit_button.pressed.connect(_on_exit_pressed)

func pause_game():
	show()
	get_tree().paused = true

func _on_resume_pressed():
	get_tree().paused = false
	hide()

func _on_restart_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_help_pressed():
	help_node.show()

func _on_exit_pressed():
	get_tree().paused = false # Wajib di-unpause dulu!
	
	# Pindah ke Main Menu menggunakan PackedScene yang dipilih di Inspector
	if main_menu_scene:
		get_tree().change_scene_to_packed(main_menu_scene)
	else:
		print("Peringatan: Kamu belum memasukkan scene Main Menu di Inspector!")
		get_tree().quit() # Jika lupa pasang, tetap keluar ke desktop sebagai fail-safe
