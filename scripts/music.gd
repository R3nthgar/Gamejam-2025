extends AudioStreamPlayer2D
const TIME_FOR_ADVENTURE = preload("res://assets/brackeys_platformer_assets/music/time_for_adventure.mp3")
const WRECKING_BALLMP_3 = preload("res://assets/brackeys_platformer_assets/music/Wrecking_Ballmp3.wav")

func switch():
	if stream==WRECKING_BALLMP_3:
		stream=TIME_FOR_ADVENTURE
	else:
		stream=WRECKING_BALLMP_3
	play(0)
