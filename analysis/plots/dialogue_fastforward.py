"""One fast-forward pie per dialogue (first playthrough), plus a .tex snippet."""

from __future__ import annotations

import sys
import textwrap
from pathlib import Path

from plots._common import (
    COLOR_PLAYED,
    COLOR_SKIPPED,
    count_dialogue_skips_first_playthrough,
    slugify,
)


NAME = "dialogue_fastforward"


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

    groups.sort(key=lambda g: (g["speaker"], g["text"]))

    for old in fig_dir.glob("dialogue_*.png"):
        old.unlink()
    for old in out_dir.glob("*.tex"):
        old.unlink()

    for idx, info in enumerate(groups, start=1):
        speaker = info["speaker"]
        skipped = info["skipped"]
        played = info["played"]
        total = skipped + played
        slug = f"{idx:02d}_{slugify(speaker)}_{slugify(info['text'])}"
        png_name = f"dialogue_{slug}.png"
        tex_name = f"dialogue_{slug}.tex"

        _draw_pie(fig_dir / png_name, speaker=speaker, text=info["text"],
                  skipped=skipped, played=played, plt=plt)

        one_line = info["text"].replace("\r", " ").replace("\n", " \\n ").strip()
        description = (
            f"Pie chart of first-playthrough behavior across {total} player(s): "
            f"{skipped} fast-forwarded (red), {played} played through (blue). "
            f"Dialogue spoken by {speaker}."
        )
        tex = (
            f"% Dialogue ({speaker}): {one_line}\n"
            f"% {description}\n"
            f"\\includegraphics{{fig/{png_name}}}"
        )
        (out_dir / tex_name).write_text(tex, encoding="utf-8")

    print(f"{NAME}: wrote {len(groups)} pie(s) -> {out_dir}/")


def _draw_pie(
    out_path: Path,
    *,
    speaker: str,
    text: str,
    skipped: int,
    played: int,
    plt,
) -> None:
    sizes = [skipped, played]
    colors = [COLOR_SKIPPED, COLOR_PLAYED]
    labels = [f"Fast-forwarded ({skipped})", f"Played through ({played})"]
    sizes_nz, colors_nz, labels_nz = [], [], []
    for s, c, l in zip(sizes, colors, labels):
        if s > 0:
            sizes_nz.append(s)
            colors_nz.append(c)
            labels_nz.append(l)

    display = text.replace("\r", " ").replace("\n", " ").strip()
    if len(display) > 240:
        display = display[:237].rstrip() + "..."
    wrapped = textwrap.fill(f"“{display}”", width=58)

    n_lines = wrapped.count("\n") + 1
    line_h_fig = 0.035
    text_top = 0.98
    text_bottom = text_top - n_lines * line_h_fig
    legend_y = text_bottom - 0.015
    pie_top = legend_y - 0.06
    pie_h = pie_top - 0.02
    pie_w = 0.85
    pie_left = (1.0 - pie_w) / 2.0

    fig, ax = plt.subplots(figsize=(5, 5.4))
    fig.text(
        0.5, text_top, wrapped,
        ha="center", va="top",
        fontsize=9, style="italic", color="#888888",
    )
    ax.set_position([pie_left, 0.02, pie_w, pie_h])
    wedges, _, _ = ax.pie(
        sizes_nz, colors=colors_nz, autopct="%1.0f%%", startangle=90,
        textprops={"fontsize": 11, "color": "white", "weight": "bold"},
    )
    ax.axis("equal")
    fig.legend(
        wedges, labels_nz,
        loc="upper center",
        bbox_to_anchor=(0.5, legend_y),
        ncol=len(labels_nz), frameon=False, fontsize=10,
    )
    fig.savefig(out_path, dpi=150, bbox_inches="tight", pad_inches=0.1)
    plt.close(fig)
