"""Parse the metrics CSV into out/extracted.json, then run each plot module.

Keeps only non-debug sessions whose player_name is listed in config.yaml.
"""

from __future__ import annotations

import csv
import json
import sys
from pathlib import Path

try:
    import yaml  # type: ignore
except ImportError:
    print("analyse: PyYAML is required. Install with: pip install pyyaml", file=sys.stderr)
    sys.exit(1)

from plots import (
    ai_usage_frequency,
    choice_changes,
    choice_distribution,
    choice_times,
    classroom_quiz_accuracy,
    first_option_bias,
    dialogue_fastforward,
    knowledge_prepost,
    knowledge_vs_engagement,
    newspaper_read_time,
    stage_durations,
    stage_runtimes,
    survey_feedback,
    survey_opinions,
    top_skipped_dialogues,
    water_pump_repeat,
)
from plots._common import load_config


ANALYSIS_DIR = Path(__file__).resolve().parent
CSV_PATH = ANALYSIS_DIR / "DiET - usage analytics.csv"
SURVEY_PATH = ANALYSIS_DIR / "VibeX Expansion - DiET group project.csv"
OUT_DIR = ANALYSIS_DIR / "out"
OUT_PATH = OUT_DIR / "extracted.json"

# Survey metadata columns (not questions).
_SURVEY_TIMESTAMP_COL = 0
_SURVEY_RESPONDENT_COL = 1
_SURVEY_TOTAL_SCORE_COL = 2
_SURVEY_GAME_USERNAME_COL = 3
_SURVEY_SKIP_QUESTIONS = {
    "Timestamp",
    "Username",
    "Total score",
    "What will be your username in the game?",
}


def _load_players() -> dict[str, str]:
    """Returns {metrics_player_name: survey_game_username}. A config players
    entry is either a string (same name in both) or a mapping {name, survey}."""
    raw = load_config().get("players") or []
    if not isinstance(raw, list):
        print("analyse: 'players' in config.yaml must be a list", file=sys.stderr)
        sys.exit(1)
    mapping: dict[str, str] = {}
    for entry in raw:
        if isinstance(entry, str):
            mapping[entry] = entry
        elif isinstance(entry, dict) and entry.get("name"):
            name = str(entry["name"])
            mapping[name] = str(entry.get("survey", name))
        else:
            print(f"analyse: bad players entry {entry!r}", file=sys.stderr)
            sys.exit(1)
    return mapping


def _load_answer_key() -> dict[str, set[str]]:
    """Returns {question: set(correct options)} from config answer_key."""
    raw = load_config().get("answer_key") or {}
    return {q: {str(o).strip() for o in opts} for q, opts in raw.items()}


def _load_surveys() -> dict[str, dict]:
    """Returns {game_username: survey_record}. Knowledge questions repeat in the
    form (pre then post); the split is the first time a question text recurs."""
    if not SURVEY_PATH.exists():
        print(f"analyse: survey CSV not found at {SURVEY_PATH}, skipping survey join", file=sys.stderr)
        return {}

    answer_key = _load_answer_key()
    surveys: dict[str, dict] = {}
    with SURVEY_PATH.open(newline="", encoding="utf-8") as f:
        reader = csv.reader(f)
        header = next(reader)
        groups = _survey_question_groups(header)
        for row in reader:
            game_username = _cell(row, _SURVEY_GAME_USERNAME_COL)
            if not game_username:
                continue
            surveys[game_username] = _survey_record(row, groups, answer_key)
    return surveys


def _grade(answer: str, correct: set[str]) -> dict:
    """Grade a ';'-separated multi-select answer against the correct set."""
    selected = {opt.strip() for opt in answer.split(";") if opt.strip()}
    hits = len(selected & correct)
    misses = len(selected - correct)
    total = len(correct)
    score = max(0.0, (hits - misses) / total) if total else 0.0
    return {"score": round(score, 3), "full_credit": selected == correct}


def _survey_question_groups(header: list[str]) -> list[dict]:
    """Group columns into questions, each owning its [Score]/[Feedback] columns."""
    groups: list[dict] = []
    current: dict | None = None
    for idx, h in enumerate(header):
        if h.endswith(" [Score]"):
            if current is not None:
                current["score"] = idx
        elif h.endswith(" [Feedback]"):
            if current is not None:
                current["feedback"] = idx
        else:
            current = {"question": h, "answer": idx}
            groups.append(current)
    return groups


def _cell(row: list[str], idx: int | None) -> str:
    return row[idx].strip() if idx is not None and idx < len(row) else ""


def _survey_record(row: list[str], groups: list[dict], answer_key: dict[str, set[str]]) -> dict:
    pre: list[dict] = []
    post: list[dict] = []
    section = pre
    seen: set[str] = set()
    for g in groups:
        q = g["question"]
        if q in _SURVEY_SKIP_QUESTIONS:
            continue
        if q in seen:
            section = post
        seen.add(q)
        answer = _cell(row, g["answer"])
        entry = {"question": q, "answer": answer}
        if q in answer_key:
            entry["graded"] = _grade(answer, answer_key[q])
        if "feedback" in g and _cell(row, g["feedback"]):
            entry["feedback"] = _cell(row, g["feedback"])
        section.append(entry)
    return {
        "respondent": _cell(row, _SURVEY_RESPONDENT_COL),
        "game_username": _cell(row, _SURVEY_GAME_USERNAME_COL),
        "total_score": _cell(row, _SURVEY_TOTAL_SCORE_COL),
        "timestamp": _cell(row, _SURVEY_TIMESTAMP_COL),
        "pre": pre,
        "post": post,
    }


def _load_records(players: dict[str, str]) -> dict[str, list[dict]]:
    records: list[tuple[str, dict]] = []
    all_names: set[str] = set()
    debug_skipped = 0
    with CSV_PATH.open(newline="", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        if reader.fieldnames is None or "logs" not in reader.fieldnames:
            print(f"analyse: CSV is missing a 'logs' column (got {reader.fieldnames})", file=sys.stderr)
            sys.exit(1)
        for i, row in enumerate(reader, start=2):
            raw = (row.get("logs") or "").strip()
            if not raw:
                continue
            try:
                parsed = json.loads(raw)
            except json.JSONDecodeError as exc:
                print(f"analyse: row {i} has invalid JSON ({exc}); skipping", file=sys.stderr)
                continue
            session = parsed.get("session") or {}
            name = session.get("player_name", "") or ""
            all_names.add(name)
            if session.get("debug", True):
                debug_skipped += 1
                continue
            records.append((name, parsed))

    print(f"Players found in raw metrics ({len(all_names)}):")
    for n in sorted(all_names):
        print(f"  - {n!r}")
    print(f"\nAllow-listed players ({len(players)}):")
    for n in sorted(players):
        print(f"  - {n}")
    print()

    by_player: dict[str, list[dict]] = {}
    not_in_allowlist_skipped = 0
    for name, parsed in records:
        if name not in players:
            not_in_allowlist_skipped += 1
            continue
        by_player.setdefault(name, []).append(parsed)

    for games in by_player.values():
        games.sort(key=lambda g: (g.get("session") or {}).get("ts_started", 0.0))

    total = sum(len(g) for g in by_player.values())
    print(
        f"analyse: loaded {len(by_player)} player(s), {total} session(s) "
        f"(skipped {debug_skipped} debug, {not_in_allowlist_skipped} not-allow-listed)"
    )
    return {name: by_player[name] for name in sorted(by_player)}


def main() -> int:
    if not CSV_PATH.exists():
        print(f"analyse: input CSV not found at {CSV_PATH}", file=sys.stderr)
        return 1

    OUT_DIR.mkdir(parents=True, exist_ok=True)
    players = _load_players()
    by_player = _load_records(players)
    surveys = _load_surveys()

    combined: dict[str, dict] = {}
    surveys_by_player: dict[str, dict] = {}
    matched = 0
    for name in sorted(by_player):
        survey = surveys.get(players.get(name, name))
        if survey is not None:
            matched += 1
        surveys_by_player[name] = survey
        combined[name] = {"metrics": by_player[name], "survey": survey}
    OUT_PATH.write_text(json.dumps(combined, indent=2, ensure_ascii=False), encoding="utf-8")
    print(f"analyse: wrote {OUT_PATH} (survey matched for {matched}/{len(by_player)} player(s))")

    dialogue_fastforward.run(by_player, OUT_DIR)
    top_skipped_dialogues.run(by_player, OUT_DIR)
    stage_durations.run(by_player, OUT_DIR)
    stage_runtimes.run(by_player, OUT_DIR)
    classroom_quiz_accuracy.run(by_player, OUT_DIR)
    water_pump_repeat.run(by_player, OUT_DIR)
    choice_times.run(by_player, OUT_DIR)
    choice_changes.run(by_player, OUT_DIR)
    first_option_bias.run(by_player, OUT_DIR)
    knowledge_prepost.run(surveys_by_player, OUT_DIR)
    newspaper_read_time.run(by_player, OUT_DIR)
    survey_opinions.run(surveys_by_player, OUT_DIR)
    survey_feedback.run(surveys_by_player, OUT_DIR)
    choice_distribution.run(by_player, OUT_DIR)
    ai_usage_frequency.run(surveys_by_player, OUT_DIR)
    knowledge_vs_engagement.run(by_player, surveys_by_player, OUT_DIR)

    return 0


if __name__ == "__main__":
    sys.exit(main())
