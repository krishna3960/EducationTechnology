import fs from "node:fs/promises"
import path from "node:path"

import Link from "next/link"
import ReactMarkdown, { type Components } from "react-markdown"
import remarkGfm from "remark-gfm"

import { Button } from "@/components/ui/button"
import { ThemeToggle } from "@/components/theme-toggle"

async function getHomeContent() {
  const file = path.join(process.cwd(), "content", "home.md")
  const raw = await fs.readFile(file, "utf8")
  // Strip comments (<!-- ... -->
  return raw.replace(/<!--[\s\S]*?-->/g, "")
}

const markdownComponents: Components = {
  h1: ({ children }) => (
    <h1 className="relative mb-2 pb-3 text-4xl font-semibold tracking-tight text-stone-900 after:absolute after:bottom-0 after:left-0 after:h-1 after:w-12 after:rounded after:bg-rose-400 dark:text-stone-100">
      {children}
    </h1>
  ),
}

export default async function Page() {
  const content = await getHomeContent()

  return (
    <main className="relative flex min-h-svh flex-col items-center bg-rose-50/60 px-6 py-16 dark:bg-stone-950">
      <div className="absolute top-4 right-4">
        <ThemeToggle />
      </div>

      <article className="prose w-full max-w-2xl prose-stone dark:prose-invert prose-a:text-rose-600 prose-a:decoration-rose-300 hover:prose-a:decoration-rose-500 dark:prose-a:text-rose-400 dark:prose-a:decoration-rose-500">
        <ReactMarkdown
          remarkPlugins={[remarkGfm]}
          components={markdownComponents}
        >
          {content}
        </ReactMarkdown>
      </article>

      <div className="mt-12 flex w-full max-w-2xl flex-col items-center gap-3">
        <Button
          asChild
          size="lg"
          className="bg-rose-400 px-10 py-6 text-base font-semibold tracking-wide text-white hover:bg-rose-500"
        >
          <Link href="/play">▶ Play</Link>
        </Button>
        <p className="text-xs text-stone-500 dark:text-stone-400">
          Runs in your browser
        </p>
      </div>
    </main>
  )
}
