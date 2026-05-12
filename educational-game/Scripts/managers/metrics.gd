class_name Metrics extends RefCounted

# Metrics entry for a single play session
class SessionEntry extends RefCounted:
	var ts_started: float = 0.0
	var ts_ended: float = 0.0
	var ts_duration: float = 0.0
	var debug: bool = false

	func to_dict() -> Dictionary:
		return {
			"ts_started": ts_started,
			"ts_ended": ts_ended,
			"ts_duration": ts_duration,
			"debug": debug,
		}

# Metrics entry for one stage
class StageEntry extends RefCounted:
	var index: int = 0
	var name: String = ""
	var ts_started: float = 0.0
	var ts_ended: float = 0.0
	var ts_duration: float = 0.0

	func to_dict() -> Dictionary:
		return {
			"index": index,
			"name": name,
			"ts_started": ts_started,
			"ts_ended": ts_ended,
			"ts_duration": ts_duration,
		}


class NewspaperEntry extends RefCounted:
	var article: String = ""
	var ts_opened: float = 0.0
	var ts_closed: float = 0.0
	var ts_duration: float = 0.0

	func to_dict() -> Dictionary:
		return {
			"article": article,
			"ts_opened": ts_opened,
			"ts_closed": ts_closed,
			"ts_duration": ts_duration,
		}

# Metrics entry for one dialogue.
class DialogueEntry extends RefCounted:
	var speaker: String = ""
	var text: String = ""
	var chars: int = 0
	var ts_started: float = 0.0
	var ts_skipped: Variant = null  # float or null
	var ts_ended: float = 0.0
	var ts_closed: float = 0.0
	var ts_duration: float = 0.0  # ts_closed - ts_ended

	func to_dict() -> Dictionary:
		return {
			"speaker": speaker,
			"text": text,
			"chars": chars,
			"ts_started": ts_started,
			"ts_skipped": ts_skipped,
			"ts_ended": ts_ended,
			"ts_closed": ts_closed,
			"ts_duration": ts_duration,
		}

# Metrics entry for one classroom quiz question.
class ClassroomQuizEntry extends RefCounted:
	var scene: String = ""
	var question: String = ""
	var answer_chosen: String = ""
	var ts_started: float = 0.0
	var ts_skipped: Variant = null  # float or null
	var ts_ended: float = 0.0
	var ts_answerchosen: float = 0.0
	var ts_duration: float = 0.0  # ts_answerchosen - ts_ended
	var answer_correct: bool = false

	func to_dict() -> Dictionary:
		return {
			"scene": scene,
			"question": question,
			"answer_chosen": answer_chosen,
			"ts_started": ts_started,
			"ts_skipped": ts_skipped,
			"ts_ended": ts_ended,
			"ts_answerchosen": ts_answerchosen,
			"ts_duration": ts_duration,
			"answer_correct": answer_correct,
		}

# Metrics for one single choice (electricity/land)
class ChoiceEntry extends RefCounted:
	var value: String = ""
	var ts_started: float = 0.0
	var ts_chosen: float = 0.0
	var ts_duration: float = 0.0

	func to_dict() -> Dictionary:
		return {
			"value": value,
			"ts_started": ts_started,
			"ts_chosen": ts_chosen,
			"ts_duration": ts_duration,
		}


var session: SessionEntry = SessionEntry.new()
var stages: Array[StageEntry] = []
var newspapers: Array[NewspaperEntry] = []
var dialogues: Array[DialogueEntry] = []
var classroom_quizzes: Array[ClassroomQuizEntry] = []
var land_choice: ChoiceEntry = null
var electricity_choice: ChoiceEntry = null


func to_dict() -> Dictionary:
	return {
		"session": session.to_dict(),
		"stages": stages.map(func(s): return s.to_dict()),
		"newspapers": newspapers.map(func(n): return n.to_dict()),
		"dialogues": dialogues.map(func(d): return d.to_dict()),
		"classroom_quizzes": classroom_quizzes.map(func(q): return q.to_dict()),
		"land_choice": land_choice.to_dict() if land_choice else null,
		"electricity_choice": electricity_choice.to_dict() if electricity_choice else null,
	}
