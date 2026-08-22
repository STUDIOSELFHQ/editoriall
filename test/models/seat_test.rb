require "test_helper"

class SeatTest < ActiveSupport::TestCase
  test "agents and humans share the masthead" do
    assert_equal 2, pieces(:house).seats.humans.count
    assert_equal 1, pieces(:house).seats.agents.count
  end
end
