module Actor
  extend ActiveSupport::Concern

  def actor_name
    name
  end

  def initials
    parts = name.to_s.split
    letters = parts.length >= 2 ? [ parts.first, parts.last ] : [ name.to_s ]
    letters.map { |part| part[0] }.join.upcase.presence || "?"
  end

  def agent?
    is_a?(Agent)
  end

  def human?
    is_a?(User)
  end
end
