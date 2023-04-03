extends Node2D

signal ball_pressed


func _on_touch_screen_button_pressed():
	emit_signal("ball_pressed", self)
