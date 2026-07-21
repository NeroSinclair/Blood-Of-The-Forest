extends Control

# Path scene game dan credit
const CREDIT_SCENE_PATH = "res://Credit.tscn"
const GAME_SCENE_PATH = "res://World/world.tscn"

@onready var start_button = $VBoxContainer/StartButton
@onready var credit_button = $VBoxContainer/CreditButton
@onready var exit_button = $VBoxContainer/ExitButton

# 1. PERBAIKAN: Menambahkan variabel tombol help yang merujuk ke node help_Button di tree kamu
@onready var help_button = $help_Button
@onready var help_node = $Help

func _ready():
	# Hubungkan semua signal tombol ke fungsinya masing-masing
	start_button.pressed.connect(_on_start_pressed)
	credit_button.pressed.connect(_on_credit_pressed)
	exit_button.pressed.connect(_on_exit_pressed)
	
	# 2. Menghubungkan tombol help_Button ke fungsi _on_help_pressed di bawah
	help_button.pressed.connect(_on_help_pressed)

func _on_start_pressed():
	get_tree().change_scene_to_file(GAME_SCENE_PATH)

func _on_exit_pressed():
	get_tree().quit()

func _on_credit_pressed():
	get_tree().change_scene_to_file(CREDIT_SCENE_PATH)

# 3. Fungsi untuk menampilkan UI panduan kontrol saat tombol dipencet
func _on_help_pressed():
	help_node.show()
