require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { is_expected.to have_many(:posts) }
    it { is_expected.to have_many(:ratings) }
  end

  describe 'validations' do
    subject { build(:user) }

    it { is_expected.to validate_presence_of(:login) }
    it { is_expected.to validate_uniqueness_of(:login) }
  end

  describe 'factory' do
    it 'creates a valid user' do
      user = build(:user)
      expect(user).to be_valid
    end
  end

  describe 'dependent destroy' do
    let(:user) { create(:user) }

    it 'destroys associated posts when user is destroyed' do
      create(:post, user: user)
      expect { user.destroy }.to change(Post, :count).by(-1)
    end

    it 'destroys associated ratings when user is destroyed' do
      post = create(:post)
      create(:rating, user: user, post: post)
      expect { user.destroy }.to change(Rating, :count).by(-1)
    end
  end
end
