import Link from "next/link"

const CHARACTER_SVG = `
<svg viewBox="0 0 200 280" xmlns="http://www.w3.org/2000/svg">
  <rect x="45" y="140" width="110" height="130" rx="18" fill="#f0f0f0"/>
  <circle cx="100" cy="158" r="5" fill="#5a3a1a"/>
  <circle cx="100" cy="175" r="5" fill="#5a3a1a"/>
  <circle cx="100" cy="192" r="5" fill="#5a3a1a"/>
  <circle cx="100" cy="209" r="5" fill="#5a3a1a"/>
  <circle cx="100" cy="226" r="5" fill="#5a3a1a"/>
  <rect x="18" y="145" width="35" height="22" rx="11" fill="#f0f0f0"/>
  <circle cx="20" cy="156" r="10" fill="#c8a882"/>
  <rect x="147" y="145" width="45" height="22" rx="11" fill="#f0f0f0"/>
  <ellipse cx="196" cy="155" rx="10" ry="8" fill="#c8a882"/>
  <rect x="84" y="118" width="32" height="28" rx="8" fill="#c8a882"/>
  <ellipse cx="100" cy="100" rx="52" ry="55" fill="#c8a882"/>
  <ellipse cx="100" cy="60" rx="58" ry="52" fill="#5a3219"/>
  <ellipse cx="55"  cy="80" rx="26" ry="28" fill="#5a3219"/>
  <ellipse cx="145" cy="80" rx="26" ry="28" fill="#5a3219"/>
  <ellipse cx="100" cy="105" rx="38" ry="42" fill="#d4b896"/>
  <ellipse cx="85"  cy="98" rx="8" ry="9" fill="white"/>
  <ellipse cx="115" cy="98" rx="8" ry="9" fill="white"/>
  <circle  cx="86"  cy="99" r="5" fill="#3a7a3a"/>
  <circle  cx="116" cy="99" r="5" fill="#3a7a3a"/>
  <circle  cx="87"  cy="97" r="2" fill="#111"/>
  <circle  cx="117" cy="97" r="2" fill="#111"/>
  <path d="M77 88 Q85 83 93 88" stroke="#5a3219" stroke-width="3" fill="none" stroke-linecap="round"/>
  <path d="M107 88 Q115 83 123 88" stroke="#5a3219" stroke-width="3" fill="none" stroke-linecap="round"/>
  <path d="M88 115 Q100 122 112 115" stroke="#5a3219" stroke-width="4" fill="none" stroke-linecap="round"/>
  <ellipse cx="100" cy="117" rx="12" ry="6" fill="#7a4a2a" opacity="0.7"/>
  <ellipse cx="100" cy="130" rx="10" ry="8" fill="#7a4a2a" opacity="0.5"/>
</svg>`

const SCENE_SVG = `
<svg viewBox="0 0 900 200" xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMidYMid slice" width="100%" height="100%">
  <rect width="900" height="200" fill="#7cc96b"/>
  <ellipse cx="80"  cy="160" rx="60" ry="20" fill="#6aab6e" opacity="0.6"/>
  <ellipse cx="300" cy="170" rx="80" ry="18" fill="#6aab6e" opacity="0.5"/>
  <ellipse cx="700" cy="155" rx="70" ry="20" fill="#6aab6e" opacity="0.6"/>
  <path d="M0 150 Q150 130 200 155 Q280 180 350 160 Q420 140 500 165 Q580 185 650 160 Q730 135 900 155 L900 200 L0 200Z" fill="#6ab4d8" opacity="0.7"/>
  <rect x="160" y="80" width="50" height="70" rx="4" fill="#e8c4e0"/>
  <polygon points="135,80 160,55 210,55 235,80" fill="#9b6fa5"/>
  <rect x="175" y="110" width="18" height="25" rx="2" fill="#c8a882"/>
  <rect x="250" y="90" width="60" height="80" rx="4" fill="#e8c4e0"/>
  <polygon points="225,90 250,62 310,62 335,90" fill="#9b6fa5"/>
  <rect x="265" y="120" width="20" height="28" rx="2" fill="#c8a882"/>
  <rect x="340" y="75" width="45" height="65" rx="4" fill="#e8c4e0"/>
  <polygon points="318,75 340,52 385,52 408,75" fill="#7a4f8a"/>
  <rect x="500" y="60" width="140" height="70" rx="6" fill="#c9a96e" opacity="0.6"/>
  <rect x="508" y="65" width="38" height="24" rx="3" fill="#d4c068"/>
  <rect x="552" y="65" width="38" height="24" rx="3" fill="#d4c068"/>
  <rect x="596" y="65" width="38" height="24" rx="3" fill="#d4c068"/>
  <rect x="508" y="95" width="38" height="24" rx="3" fill="#d4c068"/>
  <rect x="552" y="95" width="38" height="24" rx="3" fill="#d4c068"/>
  <rect x="596" y="95" width="38" height="24" rx="3" fill="#d4c068"/>
  <line x1="680" y1="30" x2="680" y2="170" stroke="#333" stroke-width="3"/>
  <line x1="660" y1="60" x2="700" y2="60" stroke="#333" stroke-width="2"/>
  <line x1="655" y1="75" x2="705" y2="75" stroke="#333" stroke-width="1.5"/>
  <line x1="680" y1="60" x2="900" y2="80"  stroke="#444" stroke-width="1.5"/>
  <line x1="680" y1="75" x2="900" y2="100" stroke="#444" stroke-width="1.5"/>
  <line x1="680" y1="60" x2="0"   y2="90"  stroke="#444" stroke-width="1.5"/>
  <ellipse cx="750" cy="145" rx="18" ry="12" fill="white"/>
  <circle  cx="762" cy="138" r="9"  fill="white"/>
  <circle  cx="740" cy="154" r="4"  fill="#888"/>
  <circle  cx="755" cy="157" r="4"  fill="#888"/>
  <ellipse cx="820" cy="130" rx="15" ry="10" fill="white"/>
  <circle  cx="830" cy="124" r="8"  fill="white"/>
  <circle  cx="812" cy="138" r="3.5" fill="#888"/>
  <circle  cx="826" cy="140" r="3.5" fill="#888"/>
  <circle cx="50"  cy="120" r="22" fill="#4a7c59"/>
  <circle cx="870" cy="110" r="22" fill="#4a7c59"/>
  <rect x="170" y="148" width="50" height="10" rx="3" fill="#b08860"/>
  <rect x="175" y="142" width="8"  height="16" rx="2" fill="#987654"/>
  <rect x="207" y="142" width="8"  height="16" rx="2" fill="#987654"/>
  <rect x="390" y="95"  width="24" height="35" rx="3" fill="#b08860"/>
  <ellipse cx="402" cy="95" rx="16" ry="10" fill="#987654"/>
</svg>`

const PAGES = [
  { href: "/", label: "About", id: "about" },
  { href: "/tool", label: "Tool", id: "tool" },
  { href: "/resources", label: "Resources", id: "resources" },
  { href: "/faq", label: "FAQ", id: "faq" },
]

export function SiteHeader({
  active,
  bubble,
}: {
  active: string
  bubble: React.ReactNode
}) {
  return (
    <>
      <div className="sheep">🐑</div>
      <div className="sheep">🐑</div>
      <div className="sheep">🐑</div>

      <nav>
        <Link className="nav-logo" href="/">
          🌿 VibeX Expansion
        </Link>
        <div className="nav-links">
          {PAGES.map((p) => (
            <Link
              key={p.id}
              href={p.href}
              className={p.id === active ? "active" : undefined}
            >
              {p.label}
            </Link>
          ))}
          <Link href="/play" className="nav-play">
            🎮 Play
          </Link>
        </div>
      </nav>

      <div className="hero">
        <div className="hero-bg" />
        <div className="hero-content">
          <div
            className="character-wrap"
            dangerouslySetInnerHTML={{ __html: CHARACTER_SVG }}
          />
          <div className="speech-bubble">
            <p>{bubble}</p>
          </div>
        </div>
      </div>

      <div className="scene-strip">
        <div
          style={{ display: "contents" }}
          dangerouslySetInnerHTML={{ __html: SCENE_SVG }}
        />
        <div className="scene-strip-overlay" />
      </div>
    </>
  )
}
