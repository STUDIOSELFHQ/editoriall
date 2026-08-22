class Desk < ApplicationRecord
  belongs_to :owner, class_name: "User"
  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships
  has_many :agents, dependent: :destroy
  has_many :pieces, dependent: :destroy
  has_many :activities, dependent: :destroy

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :join_code, presence: true, uniqueness: true

  before_validation :assign_join_code, on: :create
  before_validation :assign_slug, on: :create
  after_create :ensure_owner_membership

  def self.create_for(user, attributes = {})
    transaction do
      desk = user.owned_desks.create!(attributes)
      Agent.provision_defaults!(desk)
      desk
    end
  end

  def self.provision_home!(user)
    transaction do
      desk = create_for(user, name: "#{user.name.split.first}'s Desk")
      piece = desk.pieces.create!(
        title: "House style",
        dek: "How this desk works. Rewrite it until it sounds like you.",
        chair: user,
        body: HOUSE_STYLE,
        status: "draft"
      )
      piece.seat!(user, role: "chair")
      desk.agents.each { |agent| piece.seat!(agent, role: "agent") }
      desk.record!(user, "opened_desk", piece: piece)
      desk
    end
  end

  def member?(user)
    return false unless user
    owner_id == user.id || memberships.exists?(user_id: user.id)
  end

  def role_for(user)
    return "owner" if user && owner_id == user.id
    memberships.find_by(user: user)&.role
  end

  def record!(actor, verb, piece: nil, **payload)
    activities.create!(actor: actor, verb: verb, piece: piece, payload: payload)
  end

  def to_param
    slug
  end

  HOUSE_STYLE = <<~MARKDOWN
    # The chair, the marks, the pass

    Editoriall is a copy desk. Not a shared cursor. Not a chatbot in the margin.

    One human sits in the chair and writes the copy. Everyone else at the desk — people and agents — marks the text, argues the lede, and sends a pass. The chair accepts, rejects, or writes over it.

    ## Sit down

    Take the chair when you are the one making the sentence. Give it up when you are the one marking it. If the chair is occupied, take it only when you mean to.

    ## Mark the copy

    A mark is a note on a specific line. Quote the words you mean. Say what is wrong, missing, or better. Resolve a mark when the copy has absorbed it.

    ## Send a pass

    Agents do not type into the live copy. They sit on the masthead like anyone else, and they work in passes: a proposed revision you can read, apply, or kill. Give them a brief. The more specific the assignment, the less they invent.

    ## Keep the spine honest

    Headings in the copy become the spine. If the spine is a mess, the piece is a mess. Cut until the bones show.

    ## House voice

    Write as if a stranger will read it tomorrow and a colleague will read it tonight. Short sentences earn long ones. Specific verbs earn adjectives. If an agent wrote a line you would not speak, it does not ship.
  MARKDOWN

  private
    def ensure_owner_membership
      memberships.find_or_create_by!(user: owner) { |membership| membership.role = "owner" }
    end

    def assign_join_code
      return if join_code.present?

      loop do
        self.join_code = SecureRandom.alphanumeric(6).upcase
        break unless Desk.exists?(join_code: join_code)
      end
    end

    def assign_slug
      return if slug.present?

      base = name.to_s.parameterize.presence || "desk"
      candidate = base
      n = 2
      while Desk.exists?(slug: candidate)
        candidate = "#{base}-#{n}"
        n += 1
      end
      self.slug = candidate
    end
end
