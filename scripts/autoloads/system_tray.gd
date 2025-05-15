extends StatusIndicator

@onready var tray_menu: PopupMenu = $TrayMenu

func _ready() -> void:
	# Setup initial tray menu structure (placeholder actions)
	tray_menu.clear()
	tray_menu.add_item("Open Game Window", 0)
	tray_menu.add_item("Settings", 1)
	tray_menu.add_separator()
	tray_menu.add_item("Quit", 2)

	# Connect menu signals
	tray_menu.id_pressed.connect(_on_tray_menu_id_pressed)

func _on_tray_menu_id_pressed(id: int) -> void:
	match id:
		0:
			_open_game_window()
		1:
			_open_settings()
		2:
			_quit_game()

# Placeholder methods for future functionality
func _open_game_window() -> void:
	print("TODO: Open game window")

func _open_settings() -> void:
	print("TODO: Open settings")

func _quit_game() -> void:
	get_tree().quit()
