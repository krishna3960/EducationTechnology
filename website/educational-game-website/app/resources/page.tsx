import { SiteFooter } from "@/components/site-footer"
import { SiteHeader } from "@/components/site-header"

const basePath = process.env.NEXT_PUBLIC_BASE_PATH || ""

export default function ResourcesPage() {
  return (
    <>
      <SiteHeader
        active="resources"
        bubble={
          <>
            Explore our <span>resources</span>; teaching guides, source code,
            and everything you need to bring <span>VibeX</span> into the
            classroom! 📚
          </>
        }
      />

      <main>
        <div className="section-title">📦 Resource Page</div>
        <div className="card-grid">
          <div className="card">
            <div className="card-icon">💻</div>
            <div className="card-body">
              <h3>Source Code</h3>
              <p>
                The source code of the website and the game can be found on
                GitHub.
              </p>
              <a
                href="https://github.com/krishna3960/EducationTechnology"
                target="_blank"
                rel="noreferrer"
                className="btn"
                style={{ marginTop: "1rem", display: "inline-block" }}
              >
                📂 View Repository
              </a>
            </div>
          </div>

          <div className="card">
            <div className="card-icon">🎯</div>
            <div className="card-body">
              <h3>Recommended Audience</h3>
              <div className="tag-list">
                <span className="tag-pill">University Students</span>
                <span className="tag-pill">AI Literacy Workshops</span>
                <span className="tag-pill">Sustainability Courses</span>
                <span className="tag-pill">Digital Ethics Courses</span>
              </div>
            </div>
          </div>

          <div className="card">
            <div className="card-icon">⏱️</div>
            <div className="card-body">
              <h3>Recommended Session Duration</h3>
              <p style={{ marginTop: "0.5rem", fontSize: "1rem" }}>
                Total session: <strong>30–45 min</strong>
              </p>
              <p style={{ fontSize: "0.95rem", marginTop: "0.3rem" }}>
                Gameplay: <strong>10–15 min</strong>
              </p>
            </div>
          </div>

          <div className="card">
            <div className="card-icon">👥</div>
            <div className="card-body">
              <h3>Recommended Group Size</h3>
              <div className="tag-list">
                <span className="tag-pill">Individual play</span>
                <span className="tag-pill">Small groups of 2–4</span>
                <span className="tag-pill">Classroom of 10–30</span>
              </div>
            </div>
          </div>

          <div className="card">
            <div className="card-icon">📄</div>
            <div className="card-body">
              <h3>Educator&apos;s Guide</h3>
              <p>
                For full classroom setup instructions, session flow, discussion
                topics, learning outcomes, and facilitation guidance, download
                our official Educator&apos;s Guide.
              </p>
              <a
                href={`${basePath}/DIETSetup.pdf`}
                target="_blank"
                rel="noreferrer"
                className="btn purple"
                style={{ marginTop: "1rem", display: "inline-block" }}
              >
                ⬇️ Download Educator&apos;s Guide (PDF)
              </a>
            </div>
          </div>
        </div>
      </main>

      <SiteFooter />
    </>
  )
}
