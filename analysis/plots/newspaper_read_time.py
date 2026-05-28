"""Mean newspaper read time per article, first vs second playthrough."""

from __future__ import annotations

import sys
from pathlib import Path

from plots._common import COLOR_FIRST, COLOR_SECOND, mean, newspaper_label


NAME = "newspaper_read_time"


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

    articles: dict[str, dict[str, list[float]]] = {}
    for games in by_player.values():
        for play_idx, game in enumerate(games):
            kind = "first" if play_idx == 0 else "second" if play_idx == 1 else None
            if kind is None:
                continue
            for nw in game.get("newspapers", []):
                name = nw.get("article")
                dur = nw.get("ts_duration")
                if name is None or dur is None:
                    continue
                articles.setdefault(name, {"first": [], "second": []})[kind].append(float(dur))

    if not articles:
        print(f"{NAME}: no newspaper data found, skipping")
        return

    for old in fig_dir.glob("*.png"):
        old.unlink()
    for old in out_dir.glob("*.tex"):
        old.unlink()

    order = sorted(articles, key=lambda a: (-len(articles[a]["first"]), a))
    _draw(fig_dir / f"{NAME}.png", articles=articles, order=order, plt=plt)

    first_all = [d for a in articles.values() for d in a["first"]]
    avg_first = mean(first_all)
    (out_dir / f"{NAME}.tex").write_text(
        f"% Mean newspaper read time per article (seconds), first playthrough "
        f"(blue) vs second (orange). Overall first-playthrough mean {avg_first:.1f}s.\n"
        f"\\includegraphics{{fig/{NAME}.png}}",
        encoding="utf-8",
    )
    (out_dir / "avg_read_first.tex").write_text(
        f"% Overall mean newspaper read time on first playthrough, in seconds "
        f"(across {len(first_all)} reads).\n"
        f"{avg_first:.1f}",
        encoding="utf-8",
    )
    print(f"{NAME}: overall first-playthrough mean {avg_first:.1f}s -> {out_dir}/")


def _draw(out_path: Path, *, articles: dict, order: list[str], plt) -> None:
    labels = [newspaper_label(a) for a in order]
    first_means = [mean(articles[a]["first"]) for a in order]
    second_means = [mean(articles[a]["second"]) for a in order]

    x = range(len(order))
    width = 0.4
    fig, ax = plt.subplots(figsize=(max(7.0, 1.4 * len(order)), 5.0))

    bars_first = ax.bar([i - width / 2 for i in x], first_means, width,
                        label="First playthrough", color=COLOR_FIRST)
    bars_second = ax.bar([i + width / 2 for i in x], second_means, width,
                         label="Second playthrough", color=COLOR_SECOND)

    ax.set_ylabel("Mean read time (seconds)")
    ax.set_xticks(list(x))
    ax.set_xticklabels(labels, rotation=20, ha="right", fontsize=9)
    ax.spines["top"].set_visible(False)
    ax.spines["right"].set_visible(False)
    ax.legend(loc="lower left", bbox_to_anchor=(0.0, 1.02), ncol=2, frameon=False, fontsize=10)

    ax.bar_label(bars_first, fmt="%.0f", padding=2, fontsize=8)
    ax.bar_label(bars_second, fmt="%.0f", padding=2, fontsize=8)

    fig.tight_layout()
    fig.savefig(out_path, dpi=150, bbox_inches="tight")
    plt.close(fig)
