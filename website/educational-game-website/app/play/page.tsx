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
      title="VibeX Expansion"
      style={{ width: "100vw", height: "100svh", border: 0, display: "block" }}
      allow="autoplay; fullscreen; gamepad"
    />
  )
}
