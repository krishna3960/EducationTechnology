"""Share of choices that were the first-presented option (low-effort proxy).

The choice UI defaults to cycle index 0: land=FIRST, electricity=far,
water=north, so FIRST_OPTION below tracks that, not an arbitrary preference.
"""

from __future__ import annotations

from pathlib import Path


NAME = "first_option_bias"

FIRST_OPTION = {"land": "FIRST", "electricity": "far", "water": "north"}


def run(by_player: dict[str, list[dict]], out_root: Path) -> None:
    out_dir = out_root / NAME
    out_dir.mkdir(parents=True, exist_ok=True)

    total_first = 0
    total_choices = 0
    for games in by_player.values():
        if not games:
            continue
        picks, total = _count(games[0])
        total_first += picks
        total_choices += total

    if total_choices == 0:
        print(f"{NAME}: no choices found, skipping")
        return

    overall = total_first / total_choices * 100.0
    (out_dir / "first_option_rate.tex").write_text(
        f"% Overall percentage of choices that were the first-presented option "
        f"on first playthrough ({total_first} of {total_choices}).\n"
        f"{overall:.1f}",
        encoding="utf-8",
    )
    print(f"{NAME}: {total_first}/{total_choices} = {overall:.1f}% -> {out_dir}/")


def _count(game: dict) -> tuple[int, int]:
    picks = 0
    total = 0
    for value, expected in (
        (_value(game.get("land_choice")), FIRST_OPTION["land"]),
        (_value(game.get("electricity_choice")), FIRST_OPTION["electricity"]),
    ):
        if value is not None:
            total += 1
            picks += value == expected
    for w in game.get("water_choices") or []:
        wv = _value(w)
        if wv is not None:
            total += 1
            picks += wv == FIRST_OPTION["water"]
    return picks, total


def _value(entry):
    return entry.get("value") if isinstance(entry, dict) else None
