module Api
  module V1
    class PostsController < ApplicationController
      def create
        user = User.find_or_create_by!(login: post_params[:login])
        post = user.posts.new(post_params.except(:login))

        if post.save
          render json: post.to_json(include: :user), status: :created
        else
          render json: post.errors, status: :unprocessable_entity
        end
      rescue ActiveRecord::RecordInvalid => e
        render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
      end

      def bulk_create
        posts_attributes = params.require(:posts).map do |p|
          p.permit(:title, :body, :ip, :login).to_h
        end

        posts_by_login = posts_attributes.group_by { |p| p[:login] }
        logins = posts_by_login.keys

        existing_users = User.where(login: logins).to_a
        existing_logins = existing_users.map(&:login)
        new_logins = logins - existing_logins

        if new_logins.any?
          new_user_hashes = new_logins.map { |login| { login: login, created_at: Time.current, updated_at: Time.current } }
          User.insert_all(new_user_hashes)
          users = User.where(login: logins).to_a
        else
          users = existing_users
        end

        user_map = users.index_by(&:login)

        posts_to_create = posts_attributes.map do |attrs|
          {
            title: attrs[:title],
            body: attrs[:body],
            ip: attrs[:ip],
            user_id: user_map[attrs[:login]].id,
            created_at: Time.current,
            updated_at: Time.current
          }
        end

        Post.insert_all(posts_to_create)

        render json: { status: "created" }, status: :created
      rescue StandardError => e
        render json: { errors: e.message }, status: :unprocessable_entity
      end

      def top
        limit = params.fetch(:n, 10).to_i
        posts = Post.order(avg_rating: :desc).limit(limit).select(:id, :title, :body)
        render json: posts
      end

      private

      def post_params
        params.require(:post).permit(:title, :body, :ip, :login)
      end
    end
  end
end
