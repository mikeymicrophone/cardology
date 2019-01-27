require 'rails_helper'

RSpec.describe "interviews/new", type: :view do
  before(:each) do
    assign(:interview, Interview.new(
      :expected => false,
      :frequent => false,
      :useful => false,
      :thoughts => "MyText",
      :member => nil,
      :braintree_subscription_id => "MyString"
    ))
  end

  it "renders new interview form" do
    render

    assert_select "form[action=?][method=?]", interviews_path, "post" do

      assert_select "input[name=?]", "interview[expected]"

      assert_select "input[name=?]", "interview[frequent]"

      assert_select "input[name=?]", "interview[useful]"

      assert_select "textarea[name=?]", "interview[thoughts]"

      assert_select "input[name=?]", "interview[member_id]"

      assert_select "input[name=?]", "interview[braintree_subscription_id]"
    end
  end
end
