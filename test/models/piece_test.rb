require "test_helper"

class PieceTest < ActiveSupport::TestCase
  test "spine follows markdown headings" do
    piece = pieces(:house)
    piece.update!(body: "# Lede\n\nHello.\n\n## Nut graf\n\n### The turn\n")

    assert_equal [ 1, 2, 3 ], piece.spine.map { |heading| heading[:level] }
    assert_equal "Lede", piece.spine.first[:text]
  end

  test "take_chair! moves the chair and logs it" do
    piece = pieces(:house)
    previous = piece.take_chair!(users(:two))

    assert_equal users(:one), previous
    assert piece.in_chair?(users(:two))
    assert_equal "took_chair", piece.activities.unscoped.order(:created_at).last.verb
  end

  test "apply_pass! replaces copy and files notes" do
    piece = pieces(:house)
    pass = passes(:copy_pass)
    pass.update!(notes: [ { "quote" => "Sit down", "body" => "Make it an order." } ])

    piece.apply_pass!(pass, actor: users(:one))

    assert_includes piece.body, "Take the chair"
    assert pass.reload.applied?
    assert piece.marks.where(actor: agents(:copy)).exists?
  end
end
