class Membership < ApplicationRecord
  ROLES = %w[owner editor writer].freeze

  belongs_to :desk
  belongs_to :user

  validates :role, presence: true, inclusion: { in: ROLES }
  validates :user_id, uniqueness: { scope: :desk_id }

  after_create :seat_on_open_pieces

  private
    def seat_on_open_pieces
      desk.pieces.find_each do |piece|
        piece.seat!(user, role: "editor")
      end
    end
end
