class PassesController < ApplicationController
  before_action :load_piece
  before_action :require_member
  before_action :load_pass, only: %i[apply reject]
  before_action :require_chair, only: %i[apply reject]

  def create
    @agent = @desk.agents.find(pass_params[:agent_id])
    @pass = @piece.passes.new(
      agent: @agent,
      requested_by: current_user,
      brief: pass_params[:brief],
      status: "queued"
    )

    if @pass.save
      @piece.seat!(@agent, role: "agent")
      @desk.record!(current_user, "sent_pass", piece: @piece, agent: @agent.name)
      AgentPassJob.perform_later(@pass)
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @piece, notice: "#{@agent.name} is on a pass." }
      end
    else
      redirect_to @piece, alert: @pass.errors.full_messages.to_sentence
    end
  end

  def apply
    unless @pass.ready?
      redirect_to piece_path(@piece, pass_id: @pass.id), alert: "That pass isn't ready." and return
    end

    @piece.apply_pass!(@pass, actor: current_user)
    redirect_to @piece, notice: "#{@pass.agent.name}'s pass is in the copy."
  end

  def reject
    @pass.reject!(current_user)
    redirect_to @piece, notice: "Pass killed."
  end

  private
    def load_piece
      @piece = Piece.find(params[:piece_id])
      @desk = @piece.desk
    end

    def load_pass
      @pass = @piece.passes.find(params[:id])
    end

    def require_member
      unless @desk.member?(current_user)
        redirect_to desks_path, alert: "You're not on that desk."
      end
    end

    def require_chair
      unless @piece.in_chair?(current_user)
        redirect_to @piece, alert: "Only the writer in the chair can apply or kill a pass."
      end
    end

    def pass_params
      params.require(:pass).permit(:agent_id, :brief)
    end
end
