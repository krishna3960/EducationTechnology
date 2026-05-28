"""Distribution of options chosen per choice (first playthrough)."""

from __future__ import annotations

import sys
from pathlib import Path

from plots._common import COLOR_CATEGORY


NAME = "choice_distribution"

# (title, source key, [(value, label)], pool_all)
CHOICES = [
    ("Land", "land_choice",
     [("FIRST", "First"), ("SECOND", "Second"), ("THIRD", "Third"), ("FOURTH", "Fourth")], False),
    ("Electricity", "electricity_choice",
     [("far", "Far"), ("close", "Close")], False),
    ("Water", "water_choices",
     [("north", "North"), ("west", "West"), ("east", "East")], True),
]


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

    counts: dict[str, dict[str, int]] = {title: {} for title, *_ in CHOICES}
    for games in by_player.values():
        if not games:
            continue
        game = games[0]
        for title, key, options, pool in CHOICES:
            valid = {v for v, _ in options}
            entries = game.get(key) or []
            if not pool:
                entries = [entries] if isinstance(entries, dict) else []
            for e in entries:
                v = e.get("value") if isinstance(e, dict) else None
                if v in valid:
                    counts[title][v] = counts[title].get(v, 0) + 1

    if not any(counts.values()):
        print(f"{NAME}: no choices found, skipping")
        return

    for old in fig_dir.glob("*.png"):
        old.unlink()
    for old in out_dir.glob("*.tex"):
        old.unlink()

    _draw(fig_dir / f"{NAME}.png", counts=counts, plt=plt)
    (out_dir / f"{NAME}.tex").write_text(
        "% Number of players choosing each option per choice (first playthrough). "
        "Water pools both pump placements.\n"
        f"\\includegraphics{{fig/{NAME}.png}}",
        encoding="utf-8",
    )
    print(f"{NAME}: wrote bar chart + .tex -> {out_dir}/")


def _draw(out_path: Path, *, counts: dict[str, dict[str, int]], plt) -> None:
    fig, axes = plt.subplots(1, len(CHOICES), figsize=(4.2 * len(CHOICES), 4.0))
    if len(CHOICES) == 1:
        axes = [axes]

    for ax, (title, _key, options, _pool) in zip(axes, CHOICES):
        labels = [label for _, label in options]
        values = [counts[title].get(v, 0) for v, _ in options]
        bars = ax.bar(range(len(labels)), values,
                      color=COLOR_CATEGORY[: len(labels)], width=0.7)
        ax.set_title(title, fontsize=12)
        ax.set_xticks(range(len(labels)))
        ax.set_xticklabels(labels, fontsize=9)
        ax.spines["top"].set_visible(False)
        ax.spines["right"].set_visible(False)
        ax.margins(y=0.15)
        ax.bar_label(bars, fmt="%d", padding=2, fontsize=9)

    axes[0].set_ylabel("Players")
    fig.tight_layout()
    fig.savefig(out_path, dpi=150, bbox_inches="tight")
    plt.close(fig)
