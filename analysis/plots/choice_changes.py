"""Share of players who changed each choice on their second playthrough."""

from __future__ import annotations

import sys
from pathlib import Path

from plots._common import COLOR_FIRST


NAME = "choice_changes"


def run(by_player: dict[str, list[dict]], out_root: Path) -> None:
    try:
        import matplotlib
        matplotlib.use("Agg")
        import matplotlib.pyplot as plt
    except ImportError:
        print(f"{NAME}: matplotlib is required. Install with: pip install matplotlib", file=sys.stderr)
        return

    out_dir = out_root / NAME
    fig_dir = out_dir / "fig"
    fig_dir.mkdir(parents=True, exist_ok=True)

    # label -> [changed, total]
    counts: dict[str, list[int]] = {
        "Land": [0, 0],
        "Electricity": [0, 0],
        "Water 1": [0, 0],
        "Water 2": [0, 0],
    }

    for games in by_player.values():
        if len(games) < 2:
            continue
        first, second = games[0], games[1]
        _tally(counts["Land"], _choice_value(first, "land_choice"), _choice_value(second, "land_choice"))
        _tally(counts["Electricity"], _choice_value(first, "electricity_choice"), _choice_value(second, "electricity_choice"))
        _tally(counts["Water 1"], _water_value(first, 0), _water_value(second, 0))
        _tally(counts["Water 2"], _water_value(first, 1), _water_value(second, 1))

    if not any(c[1] for c in counts.values()):
        print(f"{NAME}: no players with two playthroughs, skipping")
        return

    png_name = f"{NAME}.png"
    for old in fig_dir.glob("*.png"):
        old.unlink()
    for old in out_dir.glob("*.tex"):
        old.unlink()

    _draw(fig_dir / png_name, counts=counts, plt=plt)

    parts = ", ".join(f"{l} {c[0]}/{c[1]}" for l, c in counts.items())
    description = (
        f"Share of players who changed each choice between first and second "
        f"playthrough ({parts})."
    )
    (out_dir / f"{NAME}.tex").write_text(
        f"% {description}\n\\includegraphics{{fig/{png_name}}}", encoding="utf-8"
    )
    print(f"{NAME}: {parts} -> {out_dir}/")


def _choice_value(game: dict, key: str):
    e = game.get(key)
    return e.get("value") if isinstance(e, dict) else None


def _water_value(game: dict, idx: int):
    water = game.get("water_choices") or []
    return water[idx].get("value") if len(water) > idx and isinstance(water[idx], dict) else None


def _tally(bucket: list[int], first_val, second_val) -> None:
    if first_val is None or second_val is None:
        return
    bucket[1] += 1
    if first_val != second_val:
        bucket[0] += 1


def _draw(out_path: Path, *, counts: dict[str, list[int]], plt) -> None:
    labels = list(counts)
    pcts = [(c[0] / c[1] * 100.0) if c[1] else 0.0 for c in counts.values()]

    fig, ax = plt.subplots(figsize=(max(6.0, 1.6 * len(labels)), 4.6))
    bars = ax.bar(range(len(labels)), pcts, width=0.6, color=COLOR_FIRST)

    ax.set_ylabel("Players who changed (%)")
    ax.set_ylim(0, 100)
    ax.set_xticks(range(len(labels)))
    ax.set_xticklabels(labels, fontsize=10)
    ax.spines["top"].set_visible(False)
    ax.spines["right"].set_visible(False)

    bar_labels = [
        f"{p:.0f}% ({c[0]}/{c[1]})" for p, c in zip(pcts, counts.values())
    ]
    ax.bar_label(bars, labels=bar_labels, padding=2, fontsize=9)

    fig.tight_layout()
    fig.savefig(out_path, dpi=150, bbox_inches="tight")
    plt.close(fig)
