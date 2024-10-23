extends Screen

func _on_tutorial_button_up() -> void:
	ScreenManager.go_to_screen("res://Screens/Tests/TestScreen.tscn")
