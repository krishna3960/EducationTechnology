"""Pre vs post knowledge scores per question, grouped bars."""

from __future__ import annotations

import sys
from pathlib import Path

from plots._common import COLOR_POST, COLOR_PRE, mean


NAME = "knowledge_prepost"

SHORT_LABELS = {
    "Which resources do AI datacenters use?": "Resources",
    "How many water resources does a single prompt need on average? Assume a water bottle is 500 ml": "Water per prompt",
    "What direct effects does AI usage have on the climate?": "Climate effects",
    "Which effects can AI datacenters have on our everyday lives?": "Everyday effects",
}


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

    order: list[str] = []
    pre: dict[str, list[float]] = {}
    post: dict[str, list[float]] = {}
    for survey in surveys_by_player.values():
        if not survey:
            continue
        for entry in survey.get("pre", []):
            if "graded" in entry:
                q = entry["question"]
                if q not in pre:
                    pre[q] = []
                    order.append(q)
                pre[q].append(entry["graded"]["score"])
        for entry in survey.get("post", []):
            if "graded" in entry:
                post.setdefault(entry["question"], []).append(entry["graded"]["score"])

    questions = [q for q in order if post.get(q)]
    if not questions:
        print(f"{NAME}: no graded survey questions found, skipping")
        return

    for old in fig_dir.glob("*.png"):
        old.unlink()
    for old in out_dir.glob("*.tex"):
        old.unlink()

    pre_means = [mean(pre[q]) * 100 for q in questions]
    post_means = [mean(post[q]) * 100 for q in questions]

    all_pre = [s for q in questions for s in pre[q]]
    all_post = [s for q in questions for s in post[q]]
    overall_pre = mean(all_pre) * 100
    overall_post = mean(all_post) * 100

    labels = [SHORT_LABELS.get(q, q[:18]) for q in questions] + ["Overall"]
    _draw(fig_dir / f"{NAME}.png", labels=labels,
          pre=pre_means + [overall_pre], post=post_means + [overall_post], plt=plt)

    gain = overall_post - overall_pre
    (out_dir / f"{NAME}.tex").write_text(
        f"% Mean knowledge score per question, before (grey) vs after (green) "
        f"playing. Overall pre {overall_pre:.0f}%, post {overall_post:.0f}%.\n"
        f"\\includegraphics{{fig/{NAME}.png}}",
        encoding="utf-8",
    )
    (out_dir / "knowledge_gain.tex").write_text(
        f"% Overall knowledge gain (post minus pre), percentage points.\n"
        f"{gain:+.1f}",
        encoding="utf-8",
    )
    print(f"{NAME}: pre {overall_pre:.0f}% -> post {overall_post:.0f}% ({gain:+.1f} pp) -> {out_dir}/")


def _draw(out_path: Path, *, labels: list[str], pre: list[float], post: list[float], plt) -> None:
    x = range(len(labels))
    width = 0.4
    fig, ax = plt.subplots(figsize=(max(7.0, 1.6 * len(labels)), 5.0))

    bars_pre = ax.bar([i - width / 2 for i in x], pre, width, label="Before", color=COLOR_PRE)
    bars_post = ax.bar([i + width / 2 for i in x], post, width, label="After", color=COLOR_POST)

    ax.set_ylabel("Mean score (%)")
    ax.set_ylim(0, 100)
    ax.set_xticks(list(x))
    ax.set_xticklabels(labels, fontsize=10)
    ax.spines["top"].set_visible(False)
    ax.spines["right"].set_visible(False)
    ax.legend(loc="lower left", bbox_to_anchor=(0.0, 1.02), ncol=2, frameon=False, fontsize=10)

    ax.bar_label(bars_pre, fmt="%.0f%%", padding=2, fontsize=8)
    ax.bar_label(bars_post, fmt="%.0f%%", padding=2, fontsize=8)

    fig.tight_layout()
    fig.savefig(out_path, dpi=150, bbox_inches="tight")
    plt.close(fig)
