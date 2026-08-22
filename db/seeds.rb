ada = User.find_or_create_by!(email_address: "ada@editoriall.test") do |user|
  user.name = "Ada Lovelace"
  user.password = "password"
end

charles = User.find_or_create_by!(email_address: "charles@editoriall.test") do |user|
  user.name = "Charles Babbage"
  user.password = "password"
end

desk = ada.desks.find_by(slug: "the-city-desk") || Desk.create_for(ada, name: "The City Desk", description: "Late copy, early coffee.")
desk.memberships.find_or_create_by!(user: charles) { |membership| membership.role = "editor" }

piece = desk.pieces.find_or_initialize_by(title: "The machine in the masthead")
if piece.new_record?
  piece.assign_attributes(
    chair: ada,
    dek: "Why agents belong on the desk, not in a chat window.",
    status: "draft",
    body: <<~MARKDOWN
      # The machine in the masthead

      Most writing tools treat the model as a sidekick. A box to the right. A command that rewrites the paragraph you already regret. That is a prompt window, not a desk.

      Editoriall seats the agent next to the human. Copy, Slot, Research — they have names, jobs, and a brief. They do not type into the live copy. They send a pass. The chair reads it, applies it, or kills it.

      ## The chair is a fact

      Simultaneous cursors pretend that writing is a race. A newsroom knows better. One person holds the piece. Everyone else marks it. When you take the chair, you are saying: I will make the sentence.

      ## Marks are specific

      A comment that floats in a sidebar is a conversation. A mark that quotes the line is an edit. Agents file marks the same way humans do. If they cannot point at the words, they do not have a note.

      ## Passes are the work

      A pass is a full revision plus a summary. It is not a suggestion chip. It is not a ghost change that lands without a name. You can read what Copy did. You can reject it. You can take the chair and write over it.

      ## What to do now

      Rewrite this piece until it sounds like your desk. Then file another. Send Copy on a pass. Mark Charles's sentences. Take the chair from each other. That is the product.
    MARKDOWN
  )
  piece.save!
  desk.record!(ada, "created_piece", piece: piece, title: piece.title)
end

piece.marks.find_or_create_by!(actor: charles, quote: "That is a prompt window, not a desk.") do |mark|
  mark.body = "Keep this line. It is the lede hiding in paragraph two."
end

copy = desk.agents.find_by!(name: "Copy")
piece.passes.find_or_create_by!(agent: copy, requested_by: charles, status: "ready") do |pass|
  pass.brief = "Tighten the lede. Do not add facts."
  pass.summary = "Moved the argument to the top and cut a hedge."
  pass.proposed_body = piece.body.sub(
    "Most writing tools treat the model as a sidekick.",
    "A chatbot beside a document is not collaboration."
  )
  pass.notes = [ { "quote" => "Simultaneous cursors pretend that writing is a race.", "body" => "This is the sharpest line. Don't bury it." } ]
end
