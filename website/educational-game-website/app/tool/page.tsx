import Link from "next/link"

import { SiteFooter } from "@/components/site-footer"
import { SiteHeader } from "@/components/site-header"

export default function ToolPage() {
  return (
    <>
      <SiteHeader
        active="tool"
        bubble={
          <>
            Ready to play? <span>Launch the game</span> and start making
            decisions that shape the future of <span>AI infrastructure</span>!
            🕹️
          </>
        }
      />

      <main>
        <div className="section-title">🛠️ Tool Page</div>
        <div className="card-grid">
          <div className="card">
            <div className="card-icon">▶️</div>
            <div className="card-body">
              <h3>Access &amp; Setup</h3>
              <p>
                This game is designed for laptop and desktop use and is not
                optimized for phones or tablets. For the best experience, we
                recommend playing with a mouse.
              </p>
              <Link
                href="/play"
                className="btn"
                style={{ marginTop: "1rem", display: "inline-block" }}
              >
                🎮 Play VibeX Expansion
              </Link>
            </div>
          </div>

          <div className="card">
            <div className="card-icon">🎬</div>
            <div className="card-body">
              <h3>Demo Video</h3>
              <p>
                A short demo video (max 5 min) illustrating the interface and
                how to interact with the game will be available here soon.
              </p>
              <div className="placeholder" style={{ marginTop: "1rem" }}>
                <div className="ph-icon">🎥</div>
                Demo video coming soon
              </div>
            </div>
          </div>
        </div>
      </main>

      <SiteFooter />
    </>
  )
}
