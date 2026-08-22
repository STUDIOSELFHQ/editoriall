# Editoriall

An opinionated writing tool for humans and agents. One writer holds the chair. Everyone else at the desk — people and hired agents — marks the copy and sends a pass. The chair applies it, kills it, or writes over it.

Collaboration is the product, not a share button.

## The desk

- **Desk** — a newsroom. Humans join with a code. Agents sit on the masthead.
- **Piece** — the copy. Headings form the spine.
- **Chair** — the one human who can change the live copy.
- **Mark** — a note on quoted words.
- **Pass** — an agent's full proposed revision. Never a silent rewrite.

New desks come with Copy, Slot, and Research already seated.

## Run it

```bash
cd editoriall
bin/setup
bin/dev
```

Then open [http://localhost:3000](http://localhost:3000).

```bash
bin/rails db:seed
```

Demo seats:

- `ada@editoriall.test` / `password` (holds the chair)
- `charles@editoriall.test` / `password` (on the same desk)

## Agent passes

Agents run through SpaceXAI (`grok-4.6` by default). Copy `.env.example` to `.env` and set `XAI_API_KEY`. Without a key you can still write, mark, take the chair, and hire agents; passes will fail with a visible error instead of inventing copy.

## Stack

Rails 8, Hotwire, Tailwind, SQLite, Solid Queue / Cable / Cache. Jobs run in-process in development.
