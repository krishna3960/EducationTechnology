"""Post-play-only opinion questions (1-5 Likert): mean rating per question."""

from __future__ import annotations

import sys
from pathlib import Path

from plots._common import COLOR_FIRST, mean, slugify


NAME = "survey_feedback"
SCALE = [1, 2, 3, 4, 5]

QUESTIONS = [
    ("How likely are you to change the way you use AI in the future", "Will change AI use"),
    ("How would you compare the effectiveness of playing our game to reading a text", "Game vs. reading a text"),
    ("How likely would you replay the game?", "Would replay"),
]


def run(surveys_by_player: dict[str, dict], out_root: Path) -> None:
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

    ratings: dict[str, list[int]] = {label: [] for _, label in QUESTIONS}
    for survey in surveys_by_player.values():
        if not survey:
            continue
        for entry in survey.get("pre", []) + survey.get("post", []):
            q = entry["question"].strip()
            for prefix, label in QUESTIONS:
                if q.startswith(prefix):
                    try:
                        ratings[label].append(int(entry["answer"]))
                    except (ValueError, TypeError):
                        pass
                    break

    if not any(ratings.values()):
        print(f"{NAME}: no feedback answers found, skipping")
        return

    for old in fig_dir.glob("*.png"):
        old.unlink()
    for old in out_dir.glob("*.tex"):
        old.unlink()

    _draw(fig_dir / f"{NAME}.png", ratings=ratings, plt=plt)
    (out_dir / f"{NAME}.tex").write_text(
        "% Mean post-play feedback rating per question on a 1-5 scale "
        "(higher = more positive).\n"
        f"\\includegraphics{{fig/{NAME}.png}}",
        encoding="utf-8",
    )

    for label, rs in ratings.items():
        if not rs:
            continue
        n = sum(1 for r in rs if r >= 3)
        pct = n / len(rs) * 100.0
        (out_dir / f"{slugify(label)}_3plus.tex").write_text(
            f"% Percentage who rated '{label}' 3 or higher ({n} of {len(rs)}).\n"
            f"{pct:.1f}",
            encoding="utf-8",
        )

    print(f"{NAME}: wrote bar chart + .tex -> {out_dir}/")


def _draw(out_path: Path, *, ratings: dict[str, list[int]], plt) -> None:
    labels = [label for _, label in QUESTIONS]
    y = list(range(len(labels)))[::-1]
    means = [mean(ratings[l]) for l in labels]

    fig, ax = plt.subplots(figsize=(8, 0.8 * len(labels) + 1.5))
    bars = ax.barh(y, means, color=COLOR_FIRST, height=0.6)

    ax.set_xlim(0, 5)
    ax.set_xticks(SCALE)
    ax.set_yticks(y)
    ax.set_yticklabels(labels, fontsize=10)
    ax.set_xlabel("Mean rating (1-5)")
    ax.spines["top"].set_visible(False)
    ax.spines["right"].set_visible(False)
    ax.bar_label(bars, fmt="%.1f", padding=4, fontsize=10)

    fig.tight_layout()
    fig.savefig(out_path, dpi=150, bbox_inches="tight")
    plt.close(fig)
