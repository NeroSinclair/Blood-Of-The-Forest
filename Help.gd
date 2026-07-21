extends Control

# Sesuai screenshot, nama nodenya adalah BackButton
@onready var back_button = $BackButton 

func _ready():
	# Hubungkan signal pressed dari tombol BACK ke fungsi penutup
	back_button.pressed.connect(_on_back_button_pressed)

func _on_back_button_pressed():
	# Cukup sembunyikan diri sendiri. 
	# Menu di bawahnya (Main Menu / Pause Menu) otomatis akan kelihatan lagi
	hide()
