class User < ApplicationRecord
  include Actor

  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :memberships, dependent: :destroy
  has_many :desks, through: :memberships
  has_many :owned_desks, class_name: "Desk", foreign_key: :owner_id, inverse_of: :owner, dependent: :destroy
  has_many :chaired_pieces, class_name: "Piece", foreign_key: :chair_id, inverse_of: :chair
  has_many :requested_passes, class_name: "Pass", foreign_key: :requested_by_id, inverse_of: :requested_by

  normalizes :email_address, with: ->(email) { email.strip.downcase }
  normalizes :name, with: ->(value) { value.strip }

  validates :name, presence: true
  validates :email_address, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  def color
    palette = %w[#1c1914 #c0392b #2c4a6e #3d5a3d #6b4c2a #4a3060]
    palette[id.to_i % palette.length]
  end
end
