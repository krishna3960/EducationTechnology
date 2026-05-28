"""Percentage of players who placed both water pumps in the same river.

Writes bare values (no trailing newline) for `\\input`, one per playthrough.
"""

from __future__ import annotations

from pathlib import Path


NAME = "water_pump_repeat"


def run(by_player: dict[str, list[dict]], out_root: Path) -> None:
    out_dir = out_root / NAME
    out_dir.mkdir(parents=True, exist_ok=True)

    for kind, play_idx in (("first", 0), ("second", 1)):
        total = 0
        same = 0
        for games in by_player.values():
            if len(games) <= play_idx:
                continue
            choices = [c.get("value") for c in games[play_idx].get("water_choices", [])]
            if len(choices) < 2:
                continue
            total += 1
            if choices[0] == choices[1]:
                same += 1

        pct = (same / total * 100.0) if total else 0.0
        tex = (
            f"% Percentage of players who placed the water pump in the same "
            f"river twice on their {kind} playthrough ({same} of {total}).\n"
            f"{pct:.1f}"
        )
        (out_dir / f"{NAME}_{kind}.tex").write_text(tex, encoding="utf-8")
        print(f"{NAME} ({kind}): {same}/{total} = {pct:.1f}%")

    print(f"{NAME}: wrote first + second -> {out_dir}/")
