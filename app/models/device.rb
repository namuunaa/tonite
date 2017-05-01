class Device < ApplicationRecord
  validates :device_id, presence: true
  validates :zip, presence: true
end
