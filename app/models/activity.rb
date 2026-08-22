class Activity < ApplicationRecord
  belongs_to :desk
  belongs_to :piece, optional: true
  belongs_to :actor, polymorphic: true

  attribute :payload, default: -> { {} }

  validates :verb, presence: true

  default_scope { order(created_at: :desc) }

  def phrase
    case verb
    when "opened_desk" then "opened the desk"
    when "created_piece" then "filed #{payload_title}"
    when "took_chair" then "took the chair"
    when "left_mark" then "marked the copy"
    when "sent_pass" then "sent #{payload['agent'] || 'an agent'} on a pass"
    when "applied_pass" then "applied #{payload['agent'] || 'an agent'}'s pass"
    when "rejected_pass" then "killed #{payload['agent'] || 'an agent'}'s pass"
    when "joined_desk" then "joined the desk"
    when "hired_agent" then "put #{payload['agent'] || 'an agent'} on the masthead"
    when "updated_copy" then "updated the copy"
    when "changed_status" then "moved the piece to #{payload['status']}"
    else verb.tr("_", " ")
    end
  end

  private
    def payload_title
      payload&.dig("title").presence || piece&.title || "a piece"
    end
end
