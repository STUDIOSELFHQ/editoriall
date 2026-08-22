class MarksController < ApplicationController
  before_action :load_piece
  before_action :require_member

  def create
    @mark = @piece.marks.new(mark_params)
    @mark.actor = current_user
    @mark.status = "open"

    if @mark.save
      @desk.record!(current_user, "left_mark", piece: @piece)
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @piece, notice: "Mark filed." }
      end
    else
      redirect_to @piece, alert: @mark.errors.full_messages.to_sentence
    end
  end

  def update
    @mark = @piece.marks.find(params[:id])
    unless @piece.in_chair?(current_user) || @mark.actor == current_user
      redirect_to @piece, alert: "You can't resolve that mark." and return
    end

    @mark.update!(status: "resolved")
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @piece }
    end
  end

  private
    def load_piece
      @piece = Piece.find(params[:piece_id])
      @desk = @piece.desk
    end

    def require_member
      unless @desk.member?(current_user)
        redirect_to desks_path, alert: "You're not on that desk."
      end
    end

    def mark_params
      params.require(:mark).permit(:quote, :body)
    end
end
