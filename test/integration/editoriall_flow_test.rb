require "test_helper"

class EditoriallFlowTest < ActionDispatch::IntegrationTest
  test "landing page is public" do
    get root_path
    assert_response :success
    assert_select "h1", /Editorial/
  end

  test "signup opens a desk with agents and house style" do
    assert_difference -> { Desk.count } => 1, -> { Agent.count } => 3, -> { Piece.count } => 1 do
      post registration_path, params: {
        user: {
          name: "Nelle Harper",
          email_address: "nelle@example.com",
          password: "password",
          password_confirmation: "password"
        }
      }
    end

    assert_redirected_to desks_path
    follow_redirect!
    assert_response :success
    assert_select "h1", "Desks"
    assert_select "a", /Desk/
  end

  test "chair writes copy and a colleague files a mark" do
    sign_in_as users(:one)
    piece = pieces(:house)

    patch piece_path(piece), params: { piece: { title: "House style", body: "# Chair\n\nHold it.", lock_version: piece.lock_version } }
    assert_redirected_to piece_path(piece)
    assert_equal "Hold it.", piece.reload.body.lines.last.strip

    sign_out
    sign_in_as users(:two)

    get piece_path(piece)
    assert_response :success
    assert_select "p", /holds the chair/

    post piece_marks_path(piece), params: { mark: { quote: "Hold it.", body: "Say who holds it." } }
    assert_redirected_to piece_path(piece)
    assert piece.marks.order(:id).last.body.include?("who holds")
  end

  test "taking the chair lets the other writer edit" do
    sign_in_as users(:two)
    piece = pieces(:house)

    post piece_chair_path(piece)
    follow_redirect!
    assert piece.reload.in_chair?(users(:two))

    patch piece_path(piece), params: { piece: { body: "Charles writing.", lock_version: piece.lock_version } }
    assert_redirected_to piece_path(piece)
    assert_equal "Charles writing.", piece.reload.body
  end

  test "join code seats a new member" do
    stranger = User.create!(name: "Guest Editor", email_address: "guest@example.com", password: "password")
    sign_in_as stranger

    post joins_path, params: { join_code: "CITY01" }
    assert_redirected_to desk_path(desks(:city))
    assert desks(:city).member?(stranger)
  end

  test "sending a pass enqueues work" do
    sign_in_as users(:one)
    piece = pieces(:house)

    assert_enqueued_with(job: AgentPassJob) do
      post piece_passes_path(piece), params: { pass: { agent_id: agents(:copy).id, brief: "Cut." } }
    end
  end

  test "chair applies a ready pass" do
    sign_in_as users(:one)
    pass = passes(:copy_pass)

    post apply_piece_pass_path(pass.piece, pass)
    follow_redirect!
    assert pass.reload.applied?
    assert_includes pass.piece.reload.body, "Take the chair"
  end
end
