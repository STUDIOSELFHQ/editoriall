class DesksController < ApplicationController
  before_action :load_desk, only: :show
  before_action :require_desk_member, only: :show

  def index
    @desks = current_user.desks.includes(:owner, :agents, :pieces).order(:name)
  end

  def show
    @pieces = @desk.pieces.includes(:chair).order(updated_at: :desc)
    @activities = @desk.activities.includes(:actor, :piece).limit(20)
    @memberships = @desk.memberships.includes(:user)
    @join = Join.new
  end

  def new
    @desk = Desk.new
  end

  def create
    @desk = Desk.create_for(current_user, desk_params)
    redirect_to @desk, notice: "Desk opened. The masthead is already seated."
  rescue ActiveRecord::RecordInvalid => error
    @desk = error.record
    render :new, status: :unprocessable_entity
  end

  private
    def desk_params
      params.require(:desk).permit(:name, :description)
    end
end
