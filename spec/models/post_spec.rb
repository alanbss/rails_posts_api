require 'rails_helper'

RSpec.describe Post, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:ratings) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:body) }
    it { is_expected.to validate_presence_of(:ip) }
  end

  describe 'factory' do
    it 'creates a valid post' do
      post = build(:post)
      expect(post).to be_valid
    end
  end

  describe 'dependent destroy' do
    let(:post) { create(:post) }

    it 'destroys associated ratings when post is destroyed' do
      user = create(:user)
      create(:rating, post: post, user: user)
      expect { post.destroy }.to change(Rating, :count).by(-1)
    end
  end

  describe 'avg_rating column' do
    let(:post) { create(:post) }
    let(:second_user) { create(:user) }
    let(:third_user) { create(:user) }

    it 'can store average rating' do
      post.update_column(:avg_rating, 4.5)
      expect(post.reload.avg_rating).to eq(4.5)
    end
  end
end
