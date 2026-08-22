require "test_helper"

class PassTest < ActiveSupport::TestCase
  class FakeClient
    def complete(*)
      {
        summary: "Cut the hedge.",
        proposed_body: "# Sit down\n\nWrite it.",
        notes: [ { quote: "Write", body: "Be specific." } ]
      }.to_json
    end
  end

  test "pass runner stores a ready pass from SpaceXAI" do
    pass = pieces(:house).passes.create!(
      agent: agents(:copy),
      requested_by: users(:one),
      brief: "Tighten.",
      status: "queued"
    )

    SpaceXai::PassRunner.new(pass, client: FakeClient.new).run

    pass.reload
    assert pass.ready?
    assert_equal "Cut the hedge.", pass.summary
    assert_includes pass.proposed_body, "Write it."
  end

  test "pass runner fails without a key" do
    pass = pieces(:house).passes.create!(
      agent: agents(:copy),
      requested_by: users(:one),
      status: "queued"
    )

    SpaceXai::PassRunner.new(pass, client: SpaceXai::Client.new(api_key: nil)).run

    assert pass.reload.failed?
    assert_match(/XAI_API_KEY/, pass.error_message)
  end
end
