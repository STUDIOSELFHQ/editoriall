require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "initials come from the name" do
    assert_equal "AL", users(:one).initials
    assert_equal "CB", users(:two).initials
  end
end
