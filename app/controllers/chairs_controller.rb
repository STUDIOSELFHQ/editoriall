class ChairsController < ApplicationController
  before_action :load_piece

  def create
    unless @desk.member?(current_user)
      redirect_to desks_path, alert: "You're not on that desk." and return
    end

    previous = @piece.take_chair!(current_user)
    notice = previous == current_user ? "You already hold the chair." : "You're in the chair."
    redirect_to @piece, notice: notice
  end

  private
    def load_piece
      @piece = Piece.find(params[:piece_id])
      @desk = @piece.desk
    end
end
