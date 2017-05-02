class User < ApplicationRecord
  validates :user_id, presence: true
  validates :city, presence: true
end
