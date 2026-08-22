require "test_helper"

class AgentTest < ActiveSupport::TestCase
  test "is an actor on the masthead" do
    agent = agents(:copy)
    assert agent.agent?
    assert_equal "Copy · Copy editor", agent.label
  end
end
