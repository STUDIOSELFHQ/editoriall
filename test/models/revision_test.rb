require "test_helper"

class RevisionTest < ActiveSupport::TestCase
  test "checkpoint stores the copy" do
    piece = pieces(:house)
    revision = piece.checkpoint!(users(:one), "Manual")
    assert_equal piece.body, revision.body
  end
end
