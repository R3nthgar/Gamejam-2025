extends Area2D
var hurting=[]
func _on_body_entered(body: Node2D) -> void:
	hurting.append(body)

func _on_body_exited(body: Node2D) -> void:
	if len(hurting)>0:
		hurting.remove_at(hurting.find(body))
	
func _physics_process(_delta: float) -> void:
	for hurtee in hurting:
		if(not hurtee.dead):
			hurtee.hurt(get_meta("Sources"))
		else:
			hurting.remove_at(hurting.find(hurtee))
