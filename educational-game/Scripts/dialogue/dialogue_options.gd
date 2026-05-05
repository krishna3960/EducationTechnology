# Typed options for Dialogue.show_dialogue().
class_name DialogueOptions
extends Resource

const DEFAULT_CHARS_PER_SEC: float = 15.0

@export var chars_per_sec: float = DEFAULT_CHARS_PER_SEC
@export var dim: bool = false
# If false the dialogue is not dismissed automatically
@export var auto_close: bool = false
