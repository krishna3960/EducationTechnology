"""Per-stage (and whole-session) average durations as bare LaTeX values.

Three files per stage (_first, _second, _overall) plus total_*. The _second
files append the signed % change vs first, e.g. `30.4 (-61\\%)`.
"""

from __future__ import annotations

from pathlib import Path

from plots._common import collect_stage_durations, mean, stage_label, stage_slug


NAME = "stage_durations"


def run(by_player: dict[str, list[dict]], out_root: Path) -> None:
    out_dir = out_root / NAME
    out_dir.mkdir(parents=True, exist_ok=True)

    stages = collect_stage_durations(by_player)
    if not stages:
        print(f"{NAME}: no stage data found, skipping")
        return
    buckets = {s["name"]: s for s in stages}

    # Whole-session totals (session.ts_duration), separate from per-stage.
    totals: dict[str, list[float]] = {"first": [], "second": [], "overall": []}
    for games in by_player.values():
        for play_idx, game in enumerate(games):
            dur = (game.get("session") or {}).get("ts_duration")
            if dur is None:
                continue
            totals["overall"].append(float(dur))
            if play_idx == 0:
                totals["first"].append(float(dur))
            elif play_idx == 1:
                totals["second"].append(float(dur))

    for old in out_dir.glob("*.tex"):
        old.unlink()

    written = 0
    for stage_name in sorted(buckets):
        kinds = buckets[stage_name]
        slug = stage_slug(stage_name)
        label = f"Average duration of the '{stage_label(stage_name)}' stage"
        for kind in ("first", "second", "overall"):
            _write_value(out_dir / f"{slug}_{kind}.tex", label, kind,
                         kinds[kind], kinds["first"])
            written += 1

    label = "Average total session duration"
    for kind in ("first", "second", "overall"):
        _write_value(out_dir / f"total_{kind}.tex", label, kind,
                     totals[kind], totals["first"])
        written += 1

    print(f"{NAME}: wrote {written} .tex file(s) across {len(buckets)} stage(s) -> {out_dir}/")


def _write_value(
    tex_path: Path,
    label: str,
    kind: str,
    samples: list[float],
    first_samples: list[float],
) -> None:
    if not samples:
        tex_path.write_text(
            f"% No data: {label} on a {kind} playthrough.\n0", encoding="utf-8"
        )
        return

    avg = mean(samples)
    body = f"{avg:.1f}"
    comment = f"% {label} on {kind} playthrough across {len(samples)} session(s), in seconds."

    if kind == "second" and first_samples:
        first_avg = mean(first_samples)
        if first_avg > 0:
            pct = (avg - first_avg) / first_avg * 100.0
            body = f"{avg:.1f} ({pct:+.0f}\\%)"
            comment += " Parenthetical = change vs first playthrough."

    tex_path.write_text(f"{comment}\n{body}", encoding="utf-8")
