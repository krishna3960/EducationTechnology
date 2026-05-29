"use client"

import { useState } from "react"

import { SiteFooter } from "@/components/site-footer"
import { SiteHeader } from "@/components/site-header"

const REFERENCES = [
  [
    "[1] Pengfei Li et al., Making AI Less “Thirsty”: Uncovering and Addressing the Secret Water Footprint of AI Models, arXiv, 2023.",
    "https://arxiv.org/abs/2304.03271",
    "arxiv.org/abs/2304.03271",
  ],
  [
    "[2] Measuring the Environmental Impact of Delivering AI at Google Scale, arXiv, 2025.",
    "https://arxiv.org/abs/2508.15734",
    "arxiv.org/abs/2508.15734",
  ],
  [
    "[3] How Hungry is AI? Benchmarking Energy, Water, and Carbon Footprint of LLM Inference, Sustainable Futures, Elsevier, 2025.",
    "https://www.sciencedirect.com/science/article/pii/S2666675825000694",
    "sciencedirect.com",
  ],
  [
    "[4] Environmental Sustainability of Large Language Models and Generative AI Systems, Elsevier, 2025.",
    "https://www.sciencedirect.com/science/article/pii/S2666389925002788",
    "sciencedirect.com",
  ],
  [
    "[5] Data Centers and Water Consumption, EESI.",
    "https://www.eesi.org/articles/view/data-centers-and-water-consumption",
    "eesi.org",
  ],
  [
    "[6] Morgan Stanley, On The Markets – Waiting for the Fall, October 2025.",
    "https://advisor.morganstanley.com/broadland-wealth-management/documents/field/b/br/broadland-wealth-management/October_2025_On_The_Markets_-_Waiting_for_the_Fall.pdf",
    "morganstanley.com",
  ],
  [
    "[7] Power Consumption and Heat Dissipation in AI Data Centers: A Comparative Analysis, ResearchGate, 2025.",
    "https://www.researchgate.net/publication/389270192_Power_Consumption_and_Heat_Dissipation_in_AI_Data_Centers_A_Comparative_Analysis",
    "researchgate.net",
  ],
  [
    "[8] AI Infrastructure Sustainability Analysis, arXiv, 2026.",
    "https://arxiv.org/html/2603.27376v1",
    "arxiv.org/html/2603.27376v1",
  ],
  [
    "[9] World Resources Institute, US Data Center Growth Impacts.",
    "https://www.wri.org/insights/us-data-center-growth-impacts",
    "wri.org",
  ],
  [
    "[10] de Vries-Gao A, The carbon and water footprints of data centers and what this could mean for artificial intelligence, Patterns, 2025.",
    "https://doi.org/10.1016/j.patter.2025.101430",
    "doi.org/10.1016/j.patter.2025.101430",
  ],
  [
    "[11] Wasserwerke Zug AG, Stromverbrauch im Haushalt. Accessed 21 May 2026.",
    "https://www.wwz.ch/de/ueber-wwz/blog/2021/strom/stromverbrauch-bestimmen",
    "wwz.ch",
  ],
  [
    "[12] Elektrizitätswerke des Kantons Zürich, Wasser sparen. Accessed 21 May 2026.",
    "https://energieshop.ekz.ch/blog/ekz-wasserspar-de",
    "ekz.ch",
  ],
  [
    "[13] Hlabisa, S, The ecology of artificial intelligence: energy, water, materials, and land limits of digital systems, Carbon Neutral Syst. 1, 19 (2025).",
    "https://doi.org/10.1007/s44438-025-00018-8",
    "doi.org/10.1007/s44438-025-00018-8",
  ],
  [
    "[14] Ben Cottier (2025), The largest AI data center campuses will soon be a fifth the size of Manhattan, epoch.ai. Accessed 21 May 2026.",
    "https://epoch.ai/data-insights/data-center-sizes",
    "epoch.ai/data-insights/data-center-sizes",
  ],
  [
    "[15] Communities Are Raising Noise Pollution Concerns About Data Centers, EESI.",
    "https://www.eesi.org/articles/view/communities-are-raising-noise-pollution-concernsabout-data-centers",
    "eesi.org",
  ],
  [
    "[16] Calculate your carbon footprint and support climate protection. Accessed 21 May 2026.",
    "https://co2.myclimate.org/en/calculate_emissions",
    "co2.myclimate.org",
  ],
  [
    "[17] Artificial Intelligence (AI) Usage Statistics 2026 | Global AI Users. Accessed 21 May 2026.",
    "https://www.theglobalstatistics.com/artificial-intelligence-ai-usage-statistics/",
    "theglobalstatistics.com",
  ],
  [
    "[18] Mansi Porwal, AI Usage Statistics In 2026: How Many People Use AI Today?, March 2026. Accessed 21 May 2026.",
    "https://www.quetext.com/blog/ai-usage-statistics-2026-how-many-people-use-ai",
    "quetext.com",
  ],
]

const FAQS = [
  {
    icon: "💧",
    q: "Where do the facts in the classroom and other scenes come from?",
    a: (
      <>
        <p>
          The environmental statistics and facts shown throughout VibeX
          Expansion are drawn from peer-reviewed academic literature and
          credible institutional sources. Below is the full reference list:
        </p>
        <div className="ref-label">References</div>
        <ol className="ref-list">
          {REFERENCES.map(([text, href, label]) => (
            <li key={href}>
              {text}{" "}
              <a href={href} target="_blank" rel="noreferrer">
                {label}
              </a>
            </li>
          ))}
        </ol>
      </>
    ),
  },
  {
    icon: "📱",
    q: "Can I play on mobile?",
    a: (
      <p>
        VibeX Expansion is designed for laptop and desktop use and is not
        optimized for phones or tablets. For the best experience, we recommend
        playing on a computer with a mouse.
      </p>
    ),
  },
  {
    icon: "🌍",
    q: "Why focus on AI's environmental impact?",
    a: (
      <p>
        Young adults are among the most active users of AI, yet many remain
        unaware of the real-world infrastructure and environmental costs behind
        the systems they use daily. VibeX Expansion aims to bridge this gap by
        making these invisible consequences visible, accessible, and encouraging
        more informed and responsible AI usage.
      </p>
    ),
  },
  {
    icon: "⚠️",
    q: "Why does the game take such a pessimistic view of AI datacenters?",
    a: (
      <>
        <p>This is a fair and important question.</p>
        <p>
          Some datacenters do invest meaningfully in sustainability by using
          renewable energy, water recycling, or waste heat recovery. These
          examples exist and deserve recognition. However, they represent the
          exception, not the rule. The vast majority of AI infrastructure
          operates without meaningful sustainability commitments, driven
          primarily by cost and speed of deployment.
        </p>
        <p>
          If VibeX Expansion only showed the best-case scenario, players might
          walk away believing that AI expansion is generally well-managed and
          environmentally sound. That would be factually incorrect and would
          defeat the purpose of the game entirely. People want to understand
          reality, even when reality is uncomfortable.
        </p>
        <p>
          We also considered showing both sides explicitly. The risk there is
          false balance: presenting a rare positive example alongside the norm
          can create the impression that both are equally common, which they are
          not. Calling the positive case out explicitly as a rare exception is
          one approach, but it also risks diluting the core message of the game.
        </p>
        <p>
          Ultimately, VibeX Expansion reflects the actual state of the industry
          as documented in the research literature. The goal is not to generate
          despair, but to motivate awareness and more conscious engagement with
          AI technologies, grounded in an honest picture of where things stand
          today.
        </p>
      </>
    ),
  },
]

export default function FaqPage() {
  const [open, setOpen] = useState<number | null>(null)

  return (
    <>
      <SiteHeader
        active="faq"
        bubble={
          <>
            Got questions? I&apos;ve got answers! Check out the <span>FAQ</span>{" "}
            below. 🙋
          </>
        }
      />

      <main>
        <div className="section-title">❓ FAQ</div>
        <div className="faq-list">
          {FAQS.map((item, i) => (
            <div key={i} className={`faq-item${open === i ? " open" : ""}`}>
              <button
                className="faq-question"
                onClick={() => setOpen(open === i ? null : i)}
              >
                <span className="faq-q-icon">{item.icon}</span>
                <span className="faq-q-text">{item.q}</span>
                <span className="faq-chevron">▼</span>
              </button>
              <div className="faq-answer">
                <div className="faq-answer-inner">{item.a}</div>
              </div>
            </div>
          ))}
        </div>
      </main>

      <SiteFooter />
    </>
  )
}
