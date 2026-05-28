"""Top-N most fast-forwarded dialogues (first playthrough) as a stacked bar."""

from __future__ import annotations

import sys
import textwrap
from pathlib import Path

from plots._common import (
    COLOR_PLAYED,
    COLOR_SKIPPED,
    count_dialogue_skips_first_playthrough,
)


NAME = "top_skipped_dialogues"
TOP_N = 5
LABEL_WRAP_WIDTH = 60
LABEL_MAX_CHARS = 180


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

    groups = count_dialogue_skips_first_playthrough(by_player)
    if not groups:
        print(f"{NAME}: no dialogues found, skipping")
        return

    groups.sort(key=lambda g: (-g["skipped"], -(g["skipped"] + g["played"]), g["speaker"]))
    top = [g for g in groups if g["skipped"] > 0][:TOP_N]
    if not top:
        print(f"{NAME}: no dialogue was ever fast-forwarded, skipping")
        return

    png_name = f"{NAME}.png"
    tex_name = f"{NAME}.tex"
    png_path = fig_dir / png_name
    tex_path = out_dir / tex_name

    for old in fig_dir.glob("*.png"):
        old.unlink()
    for old in out_dir.glob("*.tex"):
        old.unlink()

    _draw_bar(png_path, top=top, plt=plt)

    dialogue_lines = []
    for rank, info in enumerate(top, start=1):
        one_line = info["text"].replace("\r", " ").replace("\n", " \\n ").strip()
        dialogue_lines.append(
            f"%   {rank}. ({info['speaker']}, {info['skipped']} skipped / "
            f"{info['skipped'] + info['played']} total) {one_line}"
        )
    dialogue_comment = "\n".join(dialogue_lines)
    description = (
        f"Stacked horizontal bar chart of the top {len(top)} dialogues by "
        f"first-playthrough fast-forward count. Red = fast-forwarded, blue = "
        f"played through; total bar width = number of players who reached the "
        f"dialogue."
    )

    tex = (
        f"% Top {len(top)} most-fast-forwarded dialogues (first playthrough only):\n"
        f"{dialogue_comment}\n"
        f"% {description}\n"
        f"\\includegraphics{{fig/{png_name}}}"
    )
    tex_path.write_text(tex, encoding="utf-8")

    print(f"{NAME}: wrote bar chart + .tex -> {out_dir}/")


def _draw_bar(out_path: Path, *, top: list[dict], plt) -> None:
    ordered = list(top)
    labels = []
    for info in ordered:
        text = info["text"].replace("\n", " ").strip()
        if len(text) > LABEL_MAX_CHARS:
            text = text[: LABEL_MAX_CHARS - 3].rstrip() + "..."
        wrapped = textwrap.fill(f"“{text}”", width=LABEL_WRAP_WIDTH)
        labels.append(f"{info['speaker']}\n{wrapped}")

    skipped = [g["skipped"] for g in ordered]
    played = [g["played"] for g in ordered]

    fig_h = max(3.5, 1.05 * len(ordered) + 1.2)
    fig, ax = plt.subplots(figsize=(9, fig_h))

    y = list(range(len(ordered)))[::-1]  # rank 1 at top

    bars_red = ax.barh(y, skipped, color=COLOR_SKIPPED, label="Fast-forwarded")
    bars_blue = ax.barh(y, played, left=skipped, color=COLOR_PLAYED, label="Played through")

    ax.set_yticks(y)
    ax.set_yticklabels(labels, fontsize=8)
    for tick in ax.get_yticklabels():
        tick.set_color("#444444")
        tick.set_fontstyle("italic")

    ax.set_xlabel("Number of players (first playthrough)")
    ax.set_xlim(left=0)
    ax.spines["top"].set_visible(False)
    ax.spines["right"].set_visible(False)
    ax.tick_params(axis="x", labelsize=9)

    for bar, value in zip(bars_red, skipped):
        if value > 0:
            ax.text(bar.get_x() + bar.get_width() / 2, bar.get_y() + bar.get_height() / 2,
                    str(value), ha="center", va="center", color="white",
                    fontsize=10, fontweight="bold")
    for bar, value in zip(bars_blue, played):
        if value > 0:
            ax.text(bar.get_x() + bar.get_width() / 2, bar.get_y() + bar.get_height() / 2,
                    str(value), ha="center", va="center", color="white",
                    fontsize=10, fontweight="bold")

    # Negative bbox-x keeps the legend flush-left with the wrapped y labels
    # after the tight crop expands the saved bounds.
    fig.legend(
        handles=[bars_red, bars_blue],
        labels=["Fast-forwarded", "Played through"],
        loc="upper left",
        bbox_to_anchor=(-0.28, 0.99),
        bbox_transform=fig.transFigure,
        frameon=False,
        fontsize=10,
        borderaxespad=0.0,
        borderpad=0.0,
    )
    fig.subplots_adjust(top=0.92)
    fig.savefig(out_path, dpi=150, bbox_inches="tight", pad_inches=0.15)
    plt.close(fig)
