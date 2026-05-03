const basePath = process.env.NEXT_PUBLIC_BASE_PATH || ''

export default function PlayPage() {
  return (
    <iframe
      src={`${basePath}/game/index.html`}
      title="EducationalGame"
      className="h-svh w-svw border-0"
      allow="autoplay; fullscreen; gamepad"
    />
  )
}
