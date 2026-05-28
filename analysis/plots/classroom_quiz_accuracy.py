"""Classroom quiz accuracy: correct vs wrong pies, first vs second playthrough."""

from __future__ import annotations

import sys
from pathlib import Path

from plots._common import COLOR_CORRECT, COLOR_WRONG


NAME = "classroom_quiz_accuracy"


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

    first = [0, 0]   # [correct, wrong]
    second = [0, 0]
    for games in by_player.values():
        for play_idx, game in enumerate(games):
            for q in game.get("classroom_quizzes", []):
                bucket = first if play_idx == 0 else second if play_idx == 1 else None
                if bucket is None:
                    continue
                if q.get("answer_correct"):
                    bucket[0] += 1
                else:
                    bucket[1] += 1

    if sum(first) == 0 and sum(second) == 0:
        print(f"{NAME}: no classroom quiz answers found, skipping")
        return

    png_name = f"{NAME}.png"
    tex_name = f"{NAME}.tex"

    for old in fig_dir.glob("*.png"):
        old.unlink()
    for old in out_dir.glob("*.tex"):
        old.unlink()

    _draw_pies(fig_dir / png_name, first=first, second=second, plt=plt)

    description = (
        f"Classroom quiz accuracy. First playthrough: {first[0]} correct / "
        f"{first[1]} wrong. Second playthrough: {second[0]} correct / "
        f"{second[1]} wrong. Green = correct, red = wrong."
    )
    tex = (
        f"% {description}\n"
        f"\\includegraphics{{fig/{png_name}}}"
    )
    (out_dir / tex_name).write_text(tex, encoding="utf-8")

    print(f"{NAME}: wrote pie pair + .tex -> {out_dir}/")


def _draw_pies(out_path: Path, *, first: list[int], second: list[int], plt) -> None:
    fig, axes = plt.subplots(1, 2, figsize=(8, 4.2))
    for ax, (title, counts) in zip(
        axes, [("First playthrough", first), ("Second playthrough", second)]
    ):
        _draw_one(ax, title, counts)
    fig.savefig(out_path, dpi=150, bbox_inches="tight", pad_inches=0.02)
    plt.close(fig)


def _draw_one(ax, title: str, counts: list[int]) -> None:
    correct, wrong = counts
    sizes, colors, labels = [], [], []
    if correct > 0:
        sizes.append(correct)
        colors.append(COLOR_CORRECT)
        labels.append(f"Correct ({correct})")
    if wrong > 0:
        sizes.append(wrong)
        colors.append(COLOR_WRONG)
        labels.append(f"Wrong ({wrong})")

    if not sizes:
        ax.set_title(title, fontsize=12)
        ax.text(0.5, 0.5, "(no data)", ha="center", va="center", fontsize=10)
        ax.axis("off")
        return

    ax.set_title(title, fontsize=12, pad=20)
    wedges, _, _ = ax.pie(
        sizes,
        colors=colors,
        autopct="%1.0f%%",
        startangle=90,
        textprops={"fontsize": 11, "color": "white", "weight": "bold"},
    )
    ax.axis("equal")
    ax.legend(
        wedges, labels,
        loc="lower center",
        bbox_to_anchor=(0.5, 0.96),
        ncol=len(labels),
        frameon=False,
        fontsize=10,
    )
