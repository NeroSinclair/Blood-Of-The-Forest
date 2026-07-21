extends Control

# Gunakan konstanta untuk path agar mudah diubah jika folder main menu pindah
const MAIN_MENU_PATH = "res://Main menu/main_menu.tscn"

func _ready():
	# Memastikan scene credit muncul dengan benar
	pass

# Fungsi ini akan dijalankan saat tombol Back (ExitButton) ditekan
func _on_exit_button_pressed() -> void:
	# Menggunakan SceneTree untuk berpindah ke file main menu
	var error_code = get_tree().change_scene_to_file(MAIN_MENU_PATH)
	
	# Pengecekan error (best practice akademik)
	if error_code != OK:
		print("Error: Gagal memuat Main Menu. Pastikan path benar!")
