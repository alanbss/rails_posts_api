require 'rails_helper'

RSpec.describe Rating, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:post) }
    it { is_expected.to belong_to(:user) }
  end

  describe 'validations' do
    subject { build(:rating) }

    it { is_expected.to validate_presence_of(:value) }
    it { is_expected.to validate_numericality_of(:value).only_integer }
  end

  describe 'factory' do
    it 'creates a valid rating' do
      rating = build(:rating)
      expect(rating).to be_valid
    end
  end

  describe 'value validation' do
    let(:post) { create(:post) }
    let(:user) { create(:user) }

    it 'accepts values from 1 to 5' do
      (1..5).each do |value|
        rating = build(:rating, post: post, user: user, value: value)
        expect(rating).to be_valid
      end
    end

    it 'rejects values below 1' do
      rating = build(:rating, post: post, user: user, value: 0)
      rating.valid?
      expect(rating.errors[:value]).to include('must be in 1..5')
    end

    it 'rejects values above 5' do
      rating = build(:rating, post: post, user: user, value: 6)
      rating.valid?
      expect(rating.errors[:value]).to include('must be in 1..5')
    end

    it 'rejects non-integer values' do
      rating = build(:rating, post: post, user: user, value: 3.5)
      rating.valid?
      expect(rating.errors[:value]).to include('must be an integer')
    end

    it 'rejects non-numeric values' do
      rating = build(:rating, post: post, user: user, value: 'invalid')
      rating.valid?
      expect(rating.errors[:value]).to include('is not a number')
    end
  end

  describe 'database constraints' do
    it 'enforces unique constraint on user_id and post_id combination' do
      user = create(:user)
      post = create(:post)
      create(:rating, user: user, post: post, value: 5)

      duplicate_rating = build(:rating, user: user, post: post, value: 4)
      expect { duplicate_rating.save! }.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end
end
