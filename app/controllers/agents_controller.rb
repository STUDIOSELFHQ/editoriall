class AgentsController < ApplicationController
  before_action :load_desk
  before_action :require_desk_member

  def create
    if params[:template].present?
      template = Agent::TEMPLATES.find { |entry| entry[:name] == params[:template] }
      unless template
        redirect_to @desk, alert: "Unknown agent." and return
      end
      agent = @desk.agents.create!(template.merge(llm_model: Agent::DEFAULT_MODEL))
    else
      agent = @desk.agents.create!(agent_params)
    end

    @desk.record!(current_user, "hired_agent", agent: agent.name)
    redirect_to @desk, notice: "#{agent.name} is on the masthead."
  rescue ActiveRecord::RecordInvalid => error
    redirect_to @desk, alert: error.record.errors.full_messages.to_sentence
  end

  private
    def agent_params
      params.require(:agent).permit(:name, :role_title, :brief, :color)
    end
end
