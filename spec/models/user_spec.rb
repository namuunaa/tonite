require 'rails_helper'

RSpec.describe User, type: :model do
  describe("validations") do
    it "won't save without a user_id" do
      user = User.new(city: "12345")
      user.valid?
      expect(user.errors).not_to be_empty
    end
    it "won't save without a city" do
      user = User.new(user_id: "NYC")
      user.valid?
      expect(user.errors).not_to be_empty
    end
  end
end
