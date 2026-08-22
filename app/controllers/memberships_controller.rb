class MembershipsController < ApplicationController
  before_action :load_desk
  before_action :require_desk_member

  def create
    user = User.find_by(email_address: params[:email_address].to_s.strip.downcase)
    unless user
      redirect_to @desk, alert: "No one with that email has a desk yet. Share the join code instead." and return
    end

    membership = @desk.memberships.find_or_initialize_by(user: user)
    membership.role = params[:role].presence || "writer"

    if membership.save
      @desk.record!(current_user, "joined_desk") if membership.saved_change_to_id?
      redirect_to @desk, notice: "#{user.name} is on the desk."
    else
      redirect_to @desk, alert: membership.errors.full_messages.to_sentence
    end
  end

  def destroy
    membership = @desk.memberships.find(params[:id])
    if membership.user == @desk.owner
      redirect_to @desk, alert: "The owner stays." and return
    end
    unless current_user == @desk.owner || membership.user == current_user
      redirect_to @desk, alert: "You can't remove them." and return
    end

    membership.destroy!
    redirect_to @desk, notice: "#{membership.user.name} left the desk.", status: :see_other
  end
end
