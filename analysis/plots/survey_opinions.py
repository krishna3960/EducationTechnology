"""Self-report opinions asked before and after playing (1-5), grouped bars."""

from __future__ import annotations

import sys
from pathlib import Path

from plots._common import COLOR_POST, COLOR_PRE, mean


NAME = "survey_opinions"

QUESTIONS = [
    ("Are you aware of the impact of AI usage on the environment?", "Aware of impact"),
    ("Do you think your AI usage is appropriate", "Usage appropriate"),
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

    data: dict[str, dict[str, list[int]]] = {label: {"pre": [], "post": []} for _, label in QUESTIONS}
    for survey in surveys_by_player.values():
        if not survey:
            continue
        for section in ("pre", "post"):
            for entry in survey.get(section, []):
                q = entry["question"].strip()
                for prefix, label in QUESTIONS:
                    if q.startswith(prefix):
                        try:
                            data[label][section].append(int(entry["answer"]))
                        except (ValueError, TypeError):
                            pass
                        break

    if not any(d["pre"] or d["post"] for d in data.values()):
        print(f"{NAME}: no before/after opinion answers found, skipping")
        return

    for old in fig_dir.glob("*.png"):
        old.unlink()
    for old in out_dir.glob("*.tex"):
        old.unlink()

    _draw(fig_dir / f"{NAME}.png", data=data, plt=plt)
    (out_dir / f"{NAME}.tex").write_text(
        "% Mean self-report rating (1-5) before (grey) vs after (green) playing, "
        "per question.\n"
        f"\\includegraphics{{fig/{NAME}.png}}",
        encoding="utf-8",
    )
    print(f"{NAME}: wrote bar chart + .tex -> {out_dir}/")


def _draw(out_path: Path, *, data: dict[str, dict[str, list[int]]], plt) -> None:
    labels = [label for _, label in QUESTIONS]
    pre_means = [mean(data[l]["pre"]) for l in labels]
    post_means = [mean(data[l]["post"]) for l in labels]

    x = range(len(labels))
    width = 0.4
    fig, ax = plt.subplots(figsize=(max(6.0, 2.2 * len(labels)), 5.0))

    bars_pre = ax.bar([i - width / 2 for i in x], pre_means, width, label="Before", color=COLOR_PRE)
    bars_post = ax.bar([i + width / 2 for i in x], post_means, width, label="After", color=COLOR_POST)

    ax.set_ylim(0, 5)
    ax.set_ylabel("Mean rating (1-5)")
    ax.set_xticks(list(x))
    ax.set_xticklabels(labels, fontsize=10)
    ax.spines["top"].set_visible(False)
    ax.spines["right"].set_visible(False)
    ax.legend(loc="lower left", bbox_to_anchor=(0.0, 1.02), ncol=2, frameon=False, fontsize=10)

    ax.bar_label(bars_pre, fmt="%.1f", padding=3, fontsize=9)
    ax.bar_label(bars_post, fmt="%.1f", padding=3, fontsize=9)

    fig.tight_layout()
    fig.savefig(out_path, dpi=150, bbox_inches="tight")
    plt.close(fig)
