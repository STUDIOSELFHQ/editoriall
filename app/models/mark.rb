class Mark < ApplicationRecord
  STATUSES = %w[open resolved].freeze

  belongs_to :piece
  belongs_to :actor, polymorphic: true

  validates :body, presence: true

  enum :status, STATUSES.index_by(&:itself), validate: true

  scope :chronological, -> { order(created_at: :asc) }

  def resolve!
    update!(status: "resolved")
  end
end
