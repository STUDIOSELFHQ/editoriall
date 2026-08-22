class JoinsController < ApplicationController
  def create
    desk = Desk.find_by(join_code: params[:join_code].to_s.strip.upcase)
    unless desk
      redirect_to desks_path, alert: "That join code doesn't match a desk." and return
    end

    membership = desk.memberships.find_or_initialize_by(user: current_user)
    membership.role ||= "writer"

    if membership.save
      desk.record!(current_user, "joined_desk") if membership.previously_new_record? || membership.saved_change_to_id?
      redirect_to desk, notice: "You're on #{desk.name}."
    else
      redirect_to desks_path, alert: membership.errors.full_messages.to_sentence
    end
  end
end
