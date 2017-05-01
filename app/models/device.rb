class Device < ApplicationRecord
  validates :device_id, presence: true
  validates :city, presence: true
end
