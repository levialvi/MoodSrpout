import express from 'express'
import cors from 'cors'
import morgan from 'morgan'
import { nanoid } from 'nanoid'

const app = express()
const PORT = process.env.PORT || 4000

app.use(cors())
app.use(express.json())
app.use(morgan('dev'))

// In-memory store (replace with a database later)
const moods = []

// Health
app.get('/health', (req, res) => {
  res.json({ status: 'ok' })
})

// Create mood entry
app.post('/moods', (req, res) => {
  const { emoji, note, date } = req.body || {}
  if (!emoji) return res.status(400).json({ error: 'emoji is required' })
  const createdAt = date ? new Date(date).toISOString() : new Date().toISOString()
  const mood = { id: nanoid(), emoji, note: note || '', date: createdAt }
  moods.push(mood)
  res.status(201).json(mood)
})

// List moods (optionally filter by date range)
app.get('/moods', (req, res) => {
  const { from, to } = req.query
  let results = moods
  if (from || to) {
    const fromTs = from ? new Date(from).getTime() : -Infinity
    const toTs = to ? new Date(to).getTime() : Infinity
    results = moods.filter(m => {
      const t = new Date(m.date).getTime()
      return t >= fromTs && t <= toTs
    })
  }
  res.json(results)
})

// Get one
app.get('/moods/:id', (req, res) => {
  const mood = moods.find(m => m.id === req.params.id)
  if (!mood) return res.status(404).json({ error: 'not found' })
  res.json(mood)
})

// Update
app.put('/moods/:id', (req, res) => {
  const idx = moods.findIndex(m => m.id === req.params.id)
  if (idx === -1) return res.status(404).json({ error: 'not found' })
  const { emoji, note, date } = req.body || {}
  const existing = moods[idx]
  const updated = {
    ...existing,
    emoji: emoji ?? existing.emoji,
    note: note ?? existing.note,
    date: date ? new Date(date).toISOString() : existing.date,
  }
  moods[idx] = updated
  res.json(updated)
})

// Delete
app.delete('/moods/:id', (req, res) => {
  const idx = moods.findIndex(m => m.id === req.params.id)
  if (idx === -1) return res.status(404).json({ error: 'not found' })
  const [deleted] = moods.splice(idx, 1)
  res.json(deleted)
})

// Simple stats
app.get('/stats/daily', (req, res) => {
  const byDay = {}
  for (const m of moods) {
    const day = new Date(m.date).toISOString().slice(0, 10)
    byDay[day] = (byDay[day] || 0) + 1
  }
  res.json(byDay)
})

app.get('/stats/emoji', (req, res) => {
  const counts = {}
  for (const m of moods) {
    counts[m.emoji] = (counts[m.emoji] || 0) + 1
  }
  res.json(counts)
})

app.listen(PORT, () => {
  // eslint-disable-next-line no-console
  console.log(`MoodSprout API listening on http://localhost:${PORT}`)
})


