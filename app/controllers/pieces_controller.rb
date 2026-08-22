class PiecesController < ApplicationController
  before_action :load_desk, only: %i[new create]
  before_action :require_desk_member, only: %i[new create]
  before_action :load_piece, only: %i[show update]
  before_action :require_piece_member, only: %i[show update]
  before_action :require_chair, only: :update

  def show
    @piece.seat!(current_user, role: @piece.in_chair?(current_user) ? "chair" : "editor")
    @preview_pass = @piece.passes.find_by(id: params[:pass_id]) if params[:pass_id].present?
    @marks = @piece.marks.includes(:actor).chronological
    @passes = @piece.passes.includes(:agent, :requested_by).recent
    @activities = @piece.activities.includes(:actor).limit(16)
    @seats = @piece.seats.includes(:seatable)
    render layout: "editor"
  end

  def new
    @piece = @desk.pieces.new
  end

  def create
    @piece = @desk.pieces.new(piece_params)
    @piece.chair = current_user
    @piece.body = @piece.body.presence || ""

    if @piece.save
      @desk.record!(current_user, "created_piece", piece: @piece, title: @piece.title)
      redirect_to @piece, notice: "You're in the chair."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @piece.assign_attributes(piece_params)
    status_changed = @piece.will_save_change_to_status?

    if @piece.save
      @desk.record!(current_user, "changed_status", piece: @piece, status: @piece.status) if status_changed
      response.set_header("X-Piece-Lock-Version", @piece.lock_version.to_s)
      response.set_header("Access-Control-Expose-Headers", "X-Piece-Lock-Version")
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @piece }
      end
    else
      respond_to do |format|
        format.turbo_stream { render :update_failed, status: :unprocessable_entity }
        format.html { redirect_to @piece, alert: @piece.errors.full_messages.to_sentence }
      end
    end
  rescue ActiveRecord::StaleObjectError
    redirect_to @piece, alert: "The copy changed under you. Reload before writing."
  end

  private
    def load_piece
      @piece = Piece.find(params[:id])
      @desk = @piece.desk
    end

    def require_piece_member
      require_desk_member
    end

    def require_chair
      unless @piece.in_chair?(current_user)
        redirect_to @piece, alert: "Only the writer in the chair can change the copy."
      end
    end

    def piece_params
      params.require(:piece).permit(:title, :dek, :body, :status, :lock_version)
    end
end
