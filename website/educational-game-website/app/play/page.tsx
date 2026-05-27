"use client"

import { useEffect } from "react"
import { useRouter } from "next/navigation"

const basePath = process.env.NEXT_PUBLIC_BASE_PATH || ""

export default function PlayPage() {
  const router = useRouter()

  useEffect(() => {
    function onMessage(event: MessageEvent) {
      const data = event.data
      if (data && typeof data === "object" && data.type === "game-quit") {
        router.push("/")
      }
    }
    window.addEventListener("message", onMessage)
    return () => window.removeEventListener("message", onMessage)
  }, [router])

  return (
    <iframe
      src={`${basePath}/game/index.html`}
      title="EducationalGame"
      className="h-svh w-svw border-0"
      allow="autoplay; fullscreen; gamepad"
    />
  )
}
