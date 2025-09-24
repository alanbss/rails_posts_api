require 'rails_helper'

RSpec.describe "Api::V1::Posts", type: :request do
  describe "POST /api/v1/posts" do
    context "with valid parameters and a new user" do
      let(:valid_params) do
        {
          post: {
            title: 'New Post Title',
            body: 'This is the body of the new post.',
            ip: '192.168.1.1',
            login: 'new_user'
          }
        }
      end

      it "creates a new user if not exists and a new post" do
        expect { post '/api/v1/posts', params: valid_params }.to change(User, :count).by(1).and change(Post, :count).by(1).and
        (response).to have_http_status(:created)
      end
    end

    context "with invalid parameters" do
      it "returns an unprocessable entity status" do
        post '/api/v1/posts', params: { post: { title: 'No body' } }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
