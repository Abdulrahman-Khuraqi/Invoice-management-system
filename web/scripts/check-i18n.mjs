// Lists strings wrapped in t('…') that have no English entry in src/lib/en.ts.
// Usage: npm run check:i18n   (exits with 1 when something is missing)
import fs from 'node:fs'
import path from 'node:path'
import ts from 'typescript'

const files = []
const walk = (d) => fs.readdirSync(d, { withFileTypes: true }).forEach((e) => (e.isDirectory() ? walk(path.join(d, e.name)) : /\.tsx?$/.test(e.name) && files.push(path.join(d, e.name))))
walk('src')

const dict = fs.readFileSync('src/lib/en.ts', 'utf8')
const have = new Set([...dict.matchAll(/^  ("(?:[^"\\]|\\.)*"): /gm)].map((m) => JSON.parse(m[1])))

const missing = []
for (const f of files) {
  if (/lib[\\/](en|i18n)\.ts$/.test(f)) continue
  const sf = ts.createSourceFile(f, fs.readFileSync(f, 'utf8'), ts.ScriptTarget.Latest, true, f.endsWith('x') ? ts.ScriptKind.TSX : ts.ScriptKind.TS)
  const visit = (n) => {
    if (ts.isCallExpression(n) && n.expression.getText() === 't' && n.arguments.length) {
      const a = n.arguments[0]
      if ((ts.isStringLiteral(a) || ts.isNoSubstitutionTemplateLiteral(a)) && !have.has(a.text)) missing.push(`${f}: ${JSON.stringify(a.text)}`)
    }
    ts.forEachChild(n, visit)
  }
  visit(sf)
}
if (missing.length) {
  console.log(`${missing.length} string(s) without an English translation (add them to src/lib/en.ts):`)
  console.log(missing.join('\n'))
  process.exit(1)
}
console.log('All t() strings have an English translation.')
