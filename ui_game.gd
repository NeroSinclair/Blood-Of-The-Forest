extends Control

# Bagian Health Bar
var heart_red = preload("res://Player bar/Assets/LifeBarfull.png")
var heart_gray = preload("res://Player bar/Assets/LifeBarnulll.png")

@onready var hearts_container = $PlayerInfo/HeartsContainer
@onready var menu_pause = $pausemenu

func _ready():
	if menu_pause:
		menu_pause.hide()

func _on_player_darah_berubah(darah_sekarang):
	if not hearts_container: return
	var hearts = hearts_container.get_children()
	for i in range(hearts.size()):
		if i < darah_sekarang:
			hearts[i].texture = heart_red
		else:
			hearts[i].texture = heart_gray

# FUNGSI BARU: Update teks skor kill di layar
func update_kill_ui(skor_sekarang: int, target: int):
	# Pastikan kamu sudah membuat node Label bernama "LabelKill" di dalam UIGame
	if has_node("LabelKill"):
		$LabelKill.text = "Kills: " + str(skor_sekarang) + " / " + str(target)
	else:
		print("Peringatan: Node LabelKill tidak ditemukan di UIGame!")

func _on_pause_button_pressed():
	get_tree().paused = true
	menu_pause.show()
