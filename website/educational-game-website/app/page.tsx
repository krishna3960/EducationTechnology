import { SiteFooter } from "@/components/site-footer"
import { SiteHeader } from "@/components/site-header"

export default function AboutPage() {
  return (
    <>
      <SiteHeader
        active="about"
        bubble={
          <>
            Welcome to <span>VibeX Expansion</span>. The video game raising
            awareness about the <span>environmental impacts of AI</span> in a
            fun and engaging way! 🌍⚡
          </>
        }
      />

      <main>
        <div className="section-title">🌿 About Page</div>
        <div className="card-grid">
          <div className="card">
            <div className="card-icon">🎮</div>
            <div className="card-body">
              <h3>Game Content</h3>
              <p>
                VibeX Expansion is an educational game experience that explores
                the hidden environmental and societal costs of AI usage. Through
                interactive gameplay, users learn how AI centers depend on large
                amounts of energy, water, and hardware infrastructure. Users
                also gain an understanding of how to prompt more thoughtfully
                and how responsible usage can reduce resource consumption.
              </p>
            </div>
          </div>

          <div className="card">
            <div className="card-icon">🎯</div>
            <div className="card-body">
              <h3>Target User</h3>
              <p>
                VibeX&apos;s primary audience is young adults, who are among the
                most active users of AI. They regularly interact with AI
                technologies to ask questions about education, entertainment,
                and problem-solving in everyday situations. Despite the
                extensive use of AI, many young adults are unaware of its
                real-world infrastructure and environmental impact.
              </p>
            </div>
          </div>

          <div className="card">
            <div className="card-icon">📚</div>
            <div className="card-body">
              <h3>Learning Objectives</h3>
              <p>
                The main goal is to raise users&apos; awareness of the
                consequences of using AI on the world around them. Users should
                develop a better understanding of the environmental, social and
                infrastructural consequences of using AI.
              </p>
              <p style={{ marginTop: "0.6rem" }}>
                At the same time, the game is designed to encourage players to
                reflect on their own habits and develop more responsible ways of
                using AI. By linking personal actions to global consequences,
                the game aims to achieve informed and thoughtful engagement with
                AI technologies.
              </p>
            </div>
          </div>

          <div className="card">
            <div className="card-icon">🏗️</div>
            <div className="card-body">
              <h3>Design Rationale</h3>
              <p>
                In the game, players act as the CEO of a rapidly expanding AI
                centre. As demand for AI services increases, they must make
                decisions about expansion, infrastructure and resources. These
                choices directly affect the lives of nearby villages, resulting
                in more or less severe negative consequences.
              </p>
              <p style={{ marginTop: "0.6rem" }}>
                This design approach enables users to consider the topic from
                two perspectives simultaneously: that of the company managing AI
                center growth, and that of the people affected by it. The
                intention is to develop a more in-depth understanding of AI
                systems and the trade-offs involved in supporting them.
              </p>
              <p style={{ marginTop: "0.6rem" }}>
                By placing the player in the role of the decision-maker, the
                game avoids directly accusing users of their AI usage. Instead,
                it creates an environment in which players can explore the
                complexity of the issue for themselves and develop a better
                understanding of their role in the larger AI ecosystem.
              </p>
            </div>
          </div>

          <div className="card">
            <div className="card-icon">🔗</div>
            <div className="card-body">
              <h3>Related Work</h3>
              <p>
                While there are no works that directly relate to all aspects of
                this game, there are some works that relate to specific aspects
                found in VibeX Expansion.
              </p>
              <p style={{ marginTop: "0.6rem" }}>
                A large source of inspiration in the development of the VibeX
                Expansion game was taken from the game{" "}
                <a
                  href="https://research.google/ai-quests/intl/en_gb"
                  target="_blank"
                  rel="noreferrer"
                >
                  Google AI Quests
                </a>
                . While AI Quests emphasizes explaining how AI is made, VibeX
                Expansion focuses on describing the environmental impacts of AI.
                Nevertheless, both games share a similar sequential, stage-like
                progression. Each stage provides a unique opportunity for users
                to learn in a controlled yet interactive manner.
              </p>
              <p style={{ marginTop: "0.6rem" }}>
                On a technical note, both games are accessible via the browser
                and present themselves using a unique 2.5D camera angle that
                enhances the user experience without being too stimulating or
                distracting from the main pedagogical content.
              </p>
              <p style={{ marginTop: "0.6rem" }}>
                Another notable work related to this game is{" "}
                <a
                  href="https://www.ecoprompt.net/"
                  target="_blank"
                  rel="noreferrer"
                >
                  Ecoprompt
                </a>
                . This website encourages users to prompt more efficiently and
                reduce the size of prompts in order to promote more
                environmentally sustainable AI usage. This sentiment is echoed
                in VibeX Expansion&apos;s classroom scene, where users are
                educated to prompt in a more environmentally conscious manner.
              </p>
              <p style={{ marginTop: "0.6rem" }}>
                Finally, the game{" "}
                <a
                  href="https://shapes.inc/datacentersimul"
                  target="_blank"
                  rel="noreferrer"
                >
                  Datacenter Simulator
                </a>{" "}
                is another work related to VibeX Expansion. While Datacenter
                Simulator does not account for environmental impacts, it
                provides an interesting narrative into how datacenters are built
                and, in this way, is similar to many aspects of how AI centers
                in VibeX Expansion are developed.
              </p>
              <p style={{ marginTop: "0.6rem" }}>
                In this way, if one enjoys VibeX Expansion, the above sources
                can provide further entertainment and educational value.
              </p>
            </div>
          </div>

          <div className="card">
            <div className="card-icon">👥</div>
            <div className="card-body">
              <h3>Team Members</h3>
              <p>
                This game was developed by <strong>Albert Cerfeda</strong>,{" "}
                <strong>Alessia Lanini</strong>,{" "}
                <strong>Alexandra Trofimova</strong>,{" "}
                <strong>Krishna Le Moing</strong>, and{" "}
                <strong>Shreyas Parida</strong>.
              </p>
            </div>
          </div>
        </div>
      </main>

      <SiteFooter />
    </>
  )
}
