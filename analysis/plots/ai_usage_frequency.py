"""How often respondents use AI (cohort description), bar of counts."""

from __future__ import annotations

import sys
from pathlib import Path

from plots._common import COLOR_FIRST


NAME = "ai_usage_frequency"
QUESTION_PREFIX = "How often do you use AI"
ORDER = ["Daily", "Weekly", "Monthly", "Rarely", "Never"]


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

    counts: dict[str, int] = {}
    for survey in surveys_by_player.values():
        if not survey:
            continue
        for entry in survey.get("pre", []) + survey.get("post", []):
            if entry["question"].strip().startswith(QUESTION_PREFIX):
                a = entry["answer"].strip()
                if a:
                    counts[a] = counts.get(a, 0) + 1
                break

    if not counts:
        print(f"{NAME}: no usage-frequency answers found, skipping")
        return

    labels = [a for a in ORDER if a in counts] + [a for a in counts if a not in ORDER]

    for old in fig_dir.glob("*.png"):
        old.unlink()
    for old in out_dir.glob("*.tex"):
        old.unlink()

    _draw(fig_dir / f"{NAME}.png", labels=labels, values=[counts[a] for a in labels], plt=plt)
    (out_dir / f"{NAME}.tex").write_text(
        "% How often the surveyed players use AI (number of respondents).\n"
        f"\\includegraphics{{fig/{NAME}.png}}",
        encoding="utf-8",
    )
    print(f"{NAME}: {counts} -> {out_dir}/")


def _draw(out_path: Path, *, labels: list[str], values: list[int], plt) -> None:
    fig, ax = plt.subplots(figsize=(max(5.0, 1.2 * len(labels) + 1), 4.0))
    bars = ax.bar(range(len(labels)), values, color=COLOR_FIRST, width=0.6)

    ax.set_ylabel("Respondents")
    ax.set_xticks(range(len(labels)))
    ax.set_xticklabels(labels, fontsize=10)
    ax.spines["top"].set_visible(False)
    ax.spines["right"].set_visible(False)
    ax.margins(y=0.15)
    ax.bar_label(bars, fmt="%d", padding=2, fontsize=10)

    fig.tight_layout()
    fig.savefig(out_path, dpi=150, bbox_inches="tight")
    plt.close(fig)
