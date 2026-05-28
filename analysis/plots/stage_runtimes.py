"""Mean stage runtime, first vs second playthrough (grouped bar chart)."""

from __future__ import annotations

import sys
from pathlib import Path

from plots._common import (
    COLOR_FIRST,
    COLOR_SECOND,
    collect_stage_durations,
    mean,
    stage_label,
)


NAME = "stage_runtimes"


def run(by_player: dict[str, list[dict]], out_root: Path) -> None:
    try:
        import matplotlib
        matplotlib.use("Agg")
        import matplotlib.pyplot as plt
    except ImportError:
        print(
            f"{NAME}: matplotlib is required. Install with: pip install matplotlib",
            file=sys.stderr,
        )
        return

    out_dir = out_root / NAME
    fig_dir = out_dir / "fig"
    fig_dir.mkdir(parents=True, exist_ok=True)

    stages = collect_stage_durations(by_player)
    if not stages:
        print(f"{NAME}: no stage data found, skipping")
        return

    png_name = f"{NAME}.png"
    tex_name = f"{NAME}.tex"

    for old in fig_dir.glob("*.png"):
        old.unlink()
    for old in out_dir.glob("*.tex"):
        old.unlink()

    _draw_grouped_bars(fig_dir / png_name, stages=stages, plt=plt)

    description = (
        "Grouped bar chart of mean stage runtime (seconds), first playthrough "
        "(blue) vs second playthrough (orange), per stage in play order."
    )
    tex = (
        f"% {description}\n"
        f"\\includegraphics{{fig/{png_name}}}"
    )
    (out_dir / tex_name).write_text(tex, encoding="utf-8")

    print(f"{NAME}: wrote bar chart + .tex -> {out_dir}/")


def _draw_grouped_bars(out_path: Path, *, stages: list[dict], plt) -> None:
    labels = [stage_label(s["name"]) for s in stages]
    first_means = [mean(s["first"]) for s in stages]
    second_means = [mean(s["second"]) for s in stages]

    x = range(len(stages))
    width = 0.4

    fig_w = max(7.0, 1.5 * len(stages))
    fig, ax = plt.subplots(figsize=(fig_w, 5.0))

    bars_first = ax.bar([i - width / 2 for i in x], first_means, width,
                        label="First playthrough", color=COLOR_FIRST)
    bars_second = ax.bar([i + width / 2 for i in x], second_means, width,
                         label="Second playthrough", color=COLOR_SECOND)

    ax.set_ylabel("Mean runtime (seconds)")
    ax.set_xticks(list(x))
    ax.set_xticklabels(labels, rotation=20, ha="right", fontsize=9)
    ax.spines["top"].set_visible(False)
    ax.spines["right"].set_visible(False)
    ax.legend(loc="lower left", bbox_to_anchor=(0.0, 1.02), ncol=2, frameon=False, fontsize=10)

    ax.bar_label(bars_first, fmt="%.0f", padding=2, fontsize=8)
    # Second bars annotate the signed % change vs the first run.
    second_labels = []
    for f, s in zip(first_means, second_means):
        if f > 0:
            second_labels.append(f"{s:.0f}\n({(s - f) / f * 100:+.0f}%)")
        else:
            second_labels.append(f"{s:.0f}")
    ax.bar_label(bars_second, labels=second_labels, padding=2, fontsize=8)

    fig.tight_layout()
    fig.savefig(out_path, dpi=150, bbox_inches="tight")
    plt.close(fig)
