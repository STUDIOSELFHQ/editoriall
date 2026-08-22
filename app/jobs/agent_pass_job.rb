class AgentPassJob < ApplicationJob
  queue_as :default

  def perform(pass)
    SpaceXai::PassRunner.new(pass).run
  end
end
