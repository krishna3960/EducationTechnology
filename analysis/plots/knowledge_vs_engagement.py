"""Knowledge gain vs mean newspaper read time, per player (scatter)."""

from __future__ import annotations

import sys
from pathlib import Path

from plots._common import COLOR_FIRST, mean


NAME = "knowledge_vs_engagement"


def run(by_player: dict[str, list[dict]], surveys_by_player: dict[str, dict], out_root: Path) -> None:
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

    xs: list[float] = []
    ys: list[float] = []
    for name, games in by_player.items():
        survey = surveys_by_player.get(name)
        if not games or not survey:
            continue
        reads = [nw["ts_duration"] for nw in games[0].get("newspapers", [])
                 if nw.get("ts_duration") is not None]
        gain = _knowledge_gain(survey)
        if not reads or gain is None:
            continue
        xs.append(mean(reads))
        ys.append(gain)

    if len(xs) < 2:
        print(f"{NAME}: not enough paired data, skipping")
        return

    for old in fig_dir.glob("*.png"):
        old.unlink()
    for old in out_dir.glob("*.tex"):
        old.unlink()

    _draw(fig_dir / f"{NAME}.png", xs=xs, ys=ys, plt=plt)
    (out_dir / f"{NAME}.tex").write_text(
        f"% Per-player knowledge gain (pp) vs mean newspaper read time (s), "
        f"first playthrough. n={len(xs)}; indicative only given the small sample.\n"
        f"\\includegraphics{{fig/{NAME}.png}}",
        encoding="utf-8",
    )
    print(f"{NAME}: {len(xs)} points -> {out_dir}/")


def _knowledge_gain(survey: dict) -> float | None:
    pre = [e["graded"]["score"] for e in survey.get("pre", []) if "graded" in e]
    post = [e["graded"]["score"] for e in survey.get("post", []) if "graded" in e]
    if not pre or not post:
        return None
    return (mean(post) - mean(pre)) * 100.0


def _fit(xs: list[float], ys: list[float]) -> tuple[float, float] | None:
    n = len(xs)
    sx, sy = sum(xs), sum(ys)
    sxx = sum(x * x for x in xs)
    sxy = sum(x * y for x, y in zip(xs, ys))
    denom = n * sxx - sx * sx
    if denom == 0:
        return None
    slope = (n * sxy - sx * sy) / denom
    intercept = (sy - slope * sx) / n
    return slope, intercept


def _draw(out_path: Path, *, xs: list[float], ys: list[float], plt) -> None:
    fig, ax = plt.subplots(figsize=(6.5, 5.0))
    ax.scatter(xs, ys, s=60, color=COLOR_FIRST, zorder=3)

    fit = _fit(xs, ys)
    if fit is not None:
        slope, intercept = fit
        x0, x1 = min(xs), max(xs)
        ax.plot([x0, x1], [slope * x0 + intercept, slope * x1 + intercept],
                linestyle="--", color="#999999", linewidth=1.2,
                label="Indicative trend")
        ax.legend(frameon=False, fontsize=9)

    ax.set_xlabel("Mean newspaper read time (s), first playthrough")
    ax.set_ylabel("Knowledge gain (percentage points)")
    ax.spines["top"].set_visible(False)
    ax.spines["right"].set_visible(False)

    fig.tight_layout()
    fig.savefig(out_path, dpi=150, bbox_inches="tight")
    plt.close(fig)
