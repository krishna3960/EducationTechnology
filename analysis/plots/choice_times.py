"""Mean deliberation time per choice, first vs second playthrough (bar chart)."""

from __future__ import annotations

import sys
from pathlib import Path

from plots._common import COLOR_FIRST, COLOR_SECOND, mean


NAME = "choice_times"


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

    # label -> {"first": [...], "second": [...]}
    choices: dict[str, dict[str, list[float]]] = {
        "Land": {"first": [], "second": []},
        "Electricity": {"first": [], "second": []},
        "Water 1": {"first": [], "second": []},
        "Water 2": {"first": [], "second": []},
    }

    for games in by_player.values():
        for play_idx, game in enumerate(games):
            kind = "first" if play_idx == 0 else "second" if play_idx == 1 else None
            if kind is None:
                continue
            _add(choices["Land"][kind], game.get("land_choice"))
            _add(choices["Electricity"][kind], game.get("electricity_choice"))
            water = game.get("water_choices") or []
            if len(water) >= 1:
                _add(choices["Water 1"][kind], water[0])
            if len(water) >= 2:
                _add(choices["Water 2"][kind], water[1])

    if not any(b["first"] or b["second"] for b in choices.values()):
        print(f"{NAME}: no choice timings found, skipping")
        return

    png_name = f"{NAME}.png"
    for old in fig_dir.glob("*.png"):
        old.unlink()
    for old in out_dir.glob("*.tex"):
        old.unlink()

    _draw(fig_dir / png_name, choices=choices, plt=plt)

    description = (
        "Mean deliberation time per choice (seconds), first playthrough (blue) "
        "vs second (orange)."
    )
    (out_dir / f"{NAME}.tex").write_text(
        f"% {description}\n\\includegraphics{{fig/{png_name}}}", encoding="utf-8"
    )
    print(f"{NAME}: wrote bar chart + .tex -> {out_dir}/")


def _add(bucket: list[float], entry) -> None:
    if isinstance(entry, dict) and entry.get("ts_duration") is not None:
        bucket.append(float(entry["ts_duration"]))


def _draw(out_path: Path, *, choices: dict[str, dict[str, list[float]]], plt) -> None:
    labels = list(choices)
    first_means = [mean(choices[l]["first"]) for l in labels]
    second_means = [mean(choices[l]["second"]) for l in labels]

    x = range(len(labels))
    width = 0.4
    fig, ax = plt.subplots(figsize=(max(7.0, 1.6 * len(labels)), 5.0))

    bars_first = ax.bar([i - width / 2 for i in x], first_means, width,
                        label="First playthrough", color=COLOR_FIRST)
    bars_second = ax.bar([i + width / 2 for i in x], second_means, width,
                         label="Second playthrough", color=COLOR_SECOND)

    ax.set_ylabel("Mean time to choose (seconds)")
    ax.set_xticks(list(x))
    ax.set_xticklabels(labels, fontsize=10)
    ax.spines["top"].set_visible(False)
    ax.spines["right"].set_visible(False)
    ax.legend(loc="lower left", bbox_to_anchor=(0.0, 1.02), ncol=2, frameon=False, fontsize=10)

    ax.bar_label(bars_first, fmt="%.0f", padding=2, fontsize=8)
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
