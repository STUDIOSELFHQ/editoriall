class Piece < ApplicationRecord
  STATUSES = %w[draft in_review ready].freeze

  belongs_to :desk
  belongs_to :chair, class_name: "User"
  has_many :seats, dependent: :destroy
  has_many :revisions, dependent: :destroy
  has_many :marks, dependent: :destroy
  has_many :passes, dependent: :destroy
  has_many :activities, dependent: :nullify

  validates :title, presence: true
  validates :status, presence: true, inclusion: { in: STATUSES }

  before_validation :normalize_copy
  before_save :set_word_count
  after_create :seat_the_desk

  def in_chair?(user)
    user && chair_id == user.id
  end

  def seat!(seatable, role:)
    seats.find_or_initialize_by(seatable: seatable).tap do |seat|
      seat.role = role
      seat.save!
    end
  end

  def take_chair!(user)
    previous = chair
    return previous if previous == user

    transaction do
      checkpoint!(previous, "Left the chair") if previous
      update!(chair: user)
      seat!(user, role: "chair")
      seat!(previous, role: "editor") if previous
      desk.record!(user, "took_chair", piece: self, from: previous&.name)
    end
    previous
  end

  def checkpoint!(actor, note)
    revisions.create!(actor: actor, body: body, note: note, word_count: word_count)
  end

  def apply_pass!(pass, actor:)
    raise ArgumentError, "pass is not ready" unless pass.ready?

    transaction do
      checkpoint!(actor, "Before applying #{pass.agent.name}'s pass")
      update!(body: pass.proposed_body.to_s)
      Array(pass.notes).each do |note|
        next if note.blank?
        marks.create!(
          actor: pass.agent,
          quote: note["quote"].presence || note[:quote],
          body: note["body"].presence || note[:body] || "Note from pass",
          status: "open"
        )
      end
      pass.update!(status: "applied")
      desk.record!(actor, "applied_pass", piece: self, agent: pass.agent.name)
    end
  end

  def spine
    body.to_s.each_line.filter_map do |line|
      match = line.strip.match(/\A(\#{1,3})\s+(.+)\z/)
      next unless match
      { level: match[1].length, text: match[2].strip }
    end
  end

  def open_marks
    marks.where(status: "open").chronological
  end

  def status_label
    { "draft" => "Draft", "in_review" => "In review", "ready" => "Ready" }.fetch(status, status)
  end

  private
    def normalize_copy
      self.title = title.to_s.strip
      self.dek = dek.to_s.strip.presence
      self.body = body.to_s
      self.status = "draft" if status.blank?
    end

    def set_word_count
      self.word_count = body.to_s.scan(/[[:alnum:]']+/).size
    end

    def seat_the_desk
      seat!(chair, role: "chair")
      desk.users.where.not(id: chair_id).find_each { |user| seat!(user, role: "editor") }
      desk.agents.find_each { |agent| seat!(agent, role: "agent") }
    end
end
