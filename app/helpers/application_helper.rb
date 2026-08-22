module ApplicationHelper
  def wordmark(link: true)
    content = safe_join([ "Editorial", content_tag(:span, "l", class: "text-mark") ])
    if link
      link_to content, authenticated? ? desks_path : root_path, class: "wordmark"
    else
      content_tag(:span, content, class: "wordmark")
    end
  end

  def actor_initials(actor)
    content_tag(:span, actor.initials, class: "avatar", style: "background: #{actor.color}", title: actor.actor_name)
  end

  def actor_name(actor)
    actor.actor_name
  end

  def relative_time(time)
    return if time.blank?
    "#{time_ago_in_words(time)} ago"
  end

  def piece_status_class(status)
    { "draft" => "status-draft", "in_review" => "status-review", "ready" => "status-ready" }.fetch(status, "status-draft")
  end
end
