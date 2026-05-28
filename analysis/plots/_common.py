"""Shared helpers for plot modules."""

from __future__ import annotations

import re
from collections import defaultdict
from pathlib import Path


def normalize_dialogue_text(text: str, player_name: str) -> str:
    if not player_name:
        return text
    return text.replace(player_name, "{name}")


def slugify(text: str, max_len: int = 48) -> str:
    s = re.sub(r"[^A-Za-z0-9]+", "_", text).strip("_").lower()
    return (s[:max_len] or "unnamed").rstrip("_")


def count_dialogue_skips_first_playthrough(by_player: dict[str, list[dict]]) -> list[dict]:
    groups: dict[tuple[str, str], dict] = defaultdict(
        lambda: {"text": "", "speaker": "", "skipped": 0, "played": 0}
    )
    for player_name, games in by_player.items():
        if not games:
            continue
        for d in games[0].get("dialogues", []):
            speaker = d.get("speaker", "")
            norm = normalize_dialogue_text(d.get("text", ""), player_name)
            bucket = groups[(speaker, norm)]
            bucket["text"] = norm
            bucket["speaker"] = speaker
            if d.get("ts_skipped") is not None:
                bucket["skipped"] += 1
            else:
                bucket["played"] += 1
    return list(groups.values())


def collect_stage_durations(by_player: dict[str, list[dict]]) -> list[dict]:
    buckets: dict[str, dict] = {}

    def add(name: str, index: int, play_idx: int, dur: float) -> None:
        b = buckets.setdefault(
            name, {"name": name, "index": index, "first": [], "second": [], "overall": []}
        )
        b["overall"].append(float(dur))
        if play_idx == 0:
            b["first"].append(float(dur))
        elif play_idx == 1:
            b["second"].append(float(dur))

    for games in by_player.values():
        for play_idx, game in enumerate(games):
            stages = game.get("stages", [])
            for stage in stages:
                name = stage.get("name")
                dur = stage.get("ts_duration")
                if name is None or dur is None:
                    continue
                add(name, stage.get("index", 1_000_000), play_idx, dur)

            # The final dashboard stage is never logged (it's last and never
            # advances), so synthesize it from last-stage-end -> session-end.
            session = game.get("session") or {}
            session_end = session.get("ts_ended")
            if stages and session_end is not None:
                last = max(stages, key=lambda s: s.get("index", -1))
                last_end = last.get("ts_ended")
                if last_end is not None:
                    dwell = float(session_end) - float(last_end)
                    if dwell >= 0:
                        add("6 statistics", last.get("index", 5) + 1, play_idx, dwell)

    return sorted(buckets.values(), key=lambda b: b["index"])


def mean(values: list[float]) -> float:
    return sum(values) / len(values) if values else 0.0


CONFIG_PATH = Path(__file__).resolve().parent.parent / "config.yaml"
_config_cache: dict | None = None


def load_config() -> dict:
    global _config_cache
    if _config_cache is None:
        import yaml
        _config_cache = (
            yaml.safe_load(CONFIG_PATH.read_text(encoding="utf-8")) or {}
            if CONFIG_PATH.exists()
            else {}
        )
    return _config_cache


def _stage_overrides() -> dict:
    raw = load_config().get("stages")
    return raw if isinstance(raw, dict) else {}


def stage_label(name: str) -> str:
    o = _stage_overrides().get(name)
    if isinstance(o, dict) and o.get("label"):
        return str(o["label"])
    if isinstance(o, str) and o:
        return o
    parts = name.split(" ", 1)
    base = parts[1] if len(parts) == 2 and parts[0].isdigit() else name
    return base.replace("_", " ")


def stage_slug(name: str) -> str:
    o = _stage_overrides().get(name)
    if isinstance(o, dict) and o.get("slug"):
        return slugify(str(o["slug"]))
    return slugify(name)


def newspaper_label(article: str) -> str:
    raw = load_config().get("newspapers")
    o = raw.get(article) if isinstance(raw, dict) else None
    if isinstance(o, str) and o:
        return o
    return article.replace("_", " ").title()


_LATEX_ESCAPES = {
    "\\": r"\textbackslash{}",
    "&": r"\&",
    "%": r"\%",
    "$": r"\$",
    "#": r"\#",
    "_": r"\_",
    "{": r"\{",
    "}": r"\}",
    "~": r"\textasciitilde{}",
    "^": r"\textasciicircum{}",
}


def latex_escape(text: str) -> str:
    return "".join(_LATEX_ESCAPES.get(c, c) for c in text)


# Shared plot colors. Tweak here only.
COLOR_SKIPPED = "#C34D4F"
COLOR_PLAYED = "#556ED0"
COLOR_CORRECT = "#78BA7A"
COLOR_WRONG = "#E04B4B"
COLOR_FIRST = "#556ED0"
COLOR_SECOND = "#F37737"
COLOR_PRE = "#9AA7B8"
COLOR_POST = "#78BA7A"
# 5-step Likert ramp, 1 (negative, red) -> 5 (positive, green).
COLOR_LIKERT = ["#d73027", "#fc8d59", "#fee08b", "#91cf60", "#1a9850"]
# Generic qualitative palette for categorical options.
COLOR_CATEGORY = ["#556ED0", "#F37737", "#78BA7A", "#E04B4B", "#9B59B6", "#5D4037"]
