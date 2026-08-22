class Agent < ApplicationRecord
  include Actor

  DEFAULT_MODEL = "grok-4.6"

  TEMPLATES = [
    {
      name: "Copy",
      role_title: "Copy editor",
      color: "#c0392b",
      brief: "You are a copy editor on a serious desk. Fix grammar, rhythm, repetition, and unclear pronouns. Preserve the author's meaning and voice. Do not add facts. Do not inflate. Prefer cuts to rewrites. Return the full revised piece."
    },
    {
      name: "Slot",
      role_title: "Slot editor",
      color: "#2c4a6e",
      brief: "You are the slot editor. Judge structure, lede, flow, and whether the piece earns its length. Tighten the spine. Flag holes. Reorder if the argument is buried. Keep the author's voice. Return the full revised piece."
    },
    {
      name: "Research",
      role_title: "Researcher",
      color: "#3d5a3d",
      brief: "You are a researcher attached to the desk. Do not polish prose. Insert bracketed queries like [need: source for this claim] where facts are thin, and add a short suggested line of inquiry under each heading that needs it. Leave finished sentences alone. Return the full piece with your research marks in the copy."
    },
    {
      name: "Facts",
      role_title: "Fact checker",
      color: "#6b4c2a",
      brief: "You are a fact checker. Challenge specific claims. Do not rewrite for style. Where a statement is unverifiable from the text alone, wrap it in a mark-style note in the notes array and leave the copy mostly intact. If you must annotate the copy, use [unverified] inline. Return the full piece."
    },
    {
      name: "Ghost",
      role_title: "Ghost",
      color: "#4a3060",
      brief: "You are a ghostwriter for this desk. Expand outlines, notes, and half-written sections into finished prose that matches the existing voice. Do not introduce a new tone. Do not hedge. Write as the author would if they had another hour. Return the full piece."
    }
  ].freeze

  belongs_to :desk
  has_many :passes, dependent: :destroy
  has_many :seats, as: :seatable, dependent: :destroy

  validates :name, :role_title, :brief, presence: true
  validates :llm_model, presence: true

  before_validation :assign_defaults, on: :create
  after_create :seat_on_open_pieces

  def self.provision_defaults!(desk)
    TEMPLATES.first(3).each do |template|
      desk.agents.create!(template.merge(llm_model: DEFAULT_MODEL))
    end
  end

  def label
    "#{name} · #{role_title}"
  end

  private
    def assign_defaults
      self.llm_model = DEFAULT_MODEL if llm_model.blank?
      self.color = "#2c4a6e" if color.blank?
    end

    def seat_on_open_pieces
      desk.pieces.find_each { |piece| piece.seat!(self, role: "agent") }
    end
end
