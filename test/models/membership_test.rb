require "test_helper"

class MembershipTest < ActiveSupport::TestCase
  test "rejects a second seat for the same user" do
    membership = Membership.new(desk: desks(:city), user: users(:one), role: "writer")
    assert_not membership.valid?
    assert_includes membership.errors[:user_id], "has already been taken"
  end
end
