class Revision < ApplicationRecord
  belongs_to :piece
  belongs_to :actor, polymorphic: true

  validates :body, presence: true

  default_scope { order(created_at: :desc) }
end
