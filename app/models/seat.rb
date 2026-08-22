class Seat < ApplicationRecord
  ROLES = %w[chair editor agent].freeze

  belongs_to :piece
  belongs_to :seatable, polymorphic: true

  validates :role, presence: true, inclusion: { in: ROLES }
  validates :seatable_id, uniqueness: { scope: [ :piece_id, :seatable_type ] }

  scope :humans, -> { where(seatable_type: "User") }
  scope :agents, -> { where(seatable_type: "Agent") }

  def agent?
    seatable_type == "Agent"
  end
end
