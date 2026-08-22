module SpaceXai
  class PassRunner
    SCHEMA = {
      name: "editorial_pass",
      strict: true,
      schema: {
        type: "object",
        additionalProperties: false,
        required: %w[summary proposed_body notes],
        properties: {
          summary: {
            type: "string",
            description: "Two or three sentences on what you changed and why."
          },
          proposed_body: {
            type: "string",
            description: "The full revised piece in markdown, not a diff."
          },
          notes: {
            type: "array",
            items: {
              type: "object",
              additionalProperties: false,
              required: %w[quote body],
              properties: {
                quote: { type: "string", description: "A short excerpt the note refers to." },
                body: { type: "string", description: "The editorial note." }
              }
            }
          }
        }
      }
    }.freeze

    def initialize(pass, client: SpaceXai::Client.new)
      @pass = pass
      @client = client
    end

    def run
      @pass.update!(status: "running")
      content = @client.complete(
        messages: messages,
        model: @pass.agent.llm_model.presence || SpaceXai::Client::DEFAULT_MODEL,
        json_schema: SCHEMA
      )
      parsed = JSON.parse(content)
      @pass.update!(
        status: "ready",
        summary: parsed["summary"].to_s,
        proposed_body: parsed["proposed_body"].to_s,
        notes: Array(parsed["notes"])
      )
      broadcast
      @pass
    rescue SpaceXai::Error, JSON::ParserError => error
      @pass.update!(status: "failed", error_message: error.message)
      broadcast
      @pass
    end

    private
      def messages
        agent = @pass.agent
        piece = @pass.piece
        brief = @pass.brief.to_s.strip
        user_content = +""
        user_content << "Assignment from the desk:\n#{brief}\n\n" if brief.present?
        user_content << "Title: #{piece.title}\n"
        user_content << "Dek: #{piece.dek}\n" if piece.dek.present?
        user_content << "Status: #{piece.status}\n\n"
        user_content << "Copy:\n#{piece.body.presence || '(empty)'}"

        [
          { role: "system", content: system_prompt(agent) },
          { role: "user", content: user_content }
        ]
      end

      def system_prompt(agent)
        <<~PROMPT
          You are #{agent.name}, #{agent.role_title} on the Editoriall desk.
          Editoriall is a copy desk for humans and agents. You never type into the live copy.
          You return a pass: a full proposed revision plus notes.

          Your standing brief:
          #{agent.brief}

          Rules:
          - proposed_body is the complete piece in markdown, ready to apply as-is.
          - Keep headings that form the spine unless the structure is the assignment.
          - Do not invent sources, quotes, or facts.
          - notes are for the chair: specific, quoted, useful. Empty array is allowed.
          - summary is for the masthead log, not the reader.
        PROMPT
      end

      def broadcast
        Turbo::StreamsChannel.broadcast_replace_to(
          @pass.piece,
          target: ActionView::RecordIdentifier.dom_id(@pass),
          partial: "passes/pass",
          locals: { pass: @pass, piece: @pass.piece }
        )
      end
  end
end
