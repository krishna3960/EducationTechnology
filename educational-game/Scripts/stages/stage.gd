class_name Stage
extends Node2D

##  This is the abstract class for a Stage. Each stage should extend this and implement _stage_start() and _stage_end(). When the stage is finished, it should emit the "finished" signal, which will cause the StageManager to advance to the next stage.


## When this signal is emitted, the stage manager will advance to the next stage and call _stage_end. Emit this when the stage is finished.
signal finished

## The stage manager calls this method once when the stage starts.
func _stage_start() -> void:
	pass

## The stage manager calls this method once when the stage ends (i.e after finished.emit())
func _stage_end() -> void:
	pass
