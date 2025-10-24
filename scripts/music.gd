extends AudioStreamPlayer
const TIME_FOR_ADVENTURE = preload("res://assets/brackeys_platformer_assets/music/time_for_adventure.mp3")
const WRECKING_BALLMP_3 = preload("res://assets/brackeys_platformer_assets/music/Wrecking_Ballmp3.wav")
const RESISTANCE = preload("uid://dlolv4623plqx")
const I_STAND_AND_FACE_IT = preload("uid://coe2s52dflbsp")
const musictracks = [I_STAND_AND_FACE_IT, RESISTANCE]
var track=0
func trackchange(newtrack):
	if(newtrack!=track):
		stream=musictracks[newtrack]
		track=newtrack
		play(0)
