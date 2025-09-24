class Rating < ApplicationRecord
  belongs_to :post
  belongs_to :user

  validates :value, presence: true, numericality: { only_integer: true, in: 1..5 }
end
