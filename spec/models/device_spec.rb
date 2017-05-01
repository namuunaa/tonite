require 'rails_helper'

RSpec.describe Device, type: :model do
  describe("validations") do
    it "won't save without a device_id" do
      device = Device.new(zip: "12345")
      device.valid?
      expect(device.errors).not_to be_empty
    end
    it "won't save without a zip" do
      device = Device.new(device_id: "12345")
      device.valid?
      expect(device.errors).not_to be_empty
    end
  end
end
