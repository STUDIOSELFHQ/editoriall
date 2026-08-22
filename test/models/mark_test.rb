require "test_helper"

class MarkTest < ActiveSupport::TestCase
  test "resolve! closes the mark" do
    mark = marks(:lede)
    mark.resolve!
    assert_equal "resolved", mark.status
  end
end
