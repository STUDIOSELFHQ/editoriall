require "test_helper"

class ActivityTest < ActiveSupport::TestCase
  test "phrase for a pass" do
    activity = activities(:opened)
    assert_equal "opened the desk", activity.phrase
  end
end
