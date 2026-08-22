class Pass < ApplicationRecord
  STATUSES = %w[queued running ready applied rejected failed].freeze

  belongs_to :piece
  belongs_to :agent
  belongs_to :requested_by, class_name: "User"

  attribute :notes, default: -> { [] }

  enum :status, STATUSES.index_by(&:itself), validate: true

  scope :recent, -> { order(created_at: :desc) }
  scope :pending, -> { where(status: %w[queued running ready]) }

  def terminal?
    applied? || rejected? || failed?
  end

  def in_flight?
    queued? || running?
  end

  def reject!(actor)
    update!(status: "rejected")
    piece.desk.record!(actor, "rejected_pass", piece: piece, agent: agent.name)
  end
end
