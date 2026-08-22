require "test_helper"

class DeskTest < ActiveSupport::TestCase
  test "create_for seats the owner and hires default agents" do
    user = users(:one)
    desk = Desk.create_for(user, name: "Night Desk")

    assert desk.member?(user)
    assert_equal "owner", desk.role_for(user)
    assert_equal %w[Copy Slot Research], desk.agents.order(:id).map(&:name)
    assert desk.join_code.present?
    assert_equal "night-desk", desk.slug
  end

  test "provision_home! files house style with the user in the chair" do
    user = User.create!(name: "Nelle Harper", email_address: "nelle@example.com", password: "password")
    desk = Desk.provision_home!(user)
    piece = desk.pieces.sole

    assert_equal "House style", piece.title
    assert piece.in_chair?(user)
    assert_includes piece.body, "The chair, the marks, the pass"
    assert_equal 3, piece.seats.agents.count
  end
end
