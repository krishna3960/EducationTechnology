import "./globals.css"

export const metadata = {
  title: "VibeX Expansion",
  description: "An educational game about AI and the environment.",
}

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode
}>) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  )
}
