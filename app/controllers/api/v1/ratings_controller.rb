module Api
  module V1
    class RatingsController < ApplicationController
      def create
        post = Post.find(rating_params[:post_id])
        rating = post.ratings.new(rating_params)

        ActiveRecord::Base.transaction do
          rating.save!
          update_average_rating(post)
        end

        render json: { average_rating: post.reload.avg_rating }, status: :created
      rescue ActiveRecord::RecordNotUnique
        render json: { error: "You have already rated this post." }, status: :unprocessable_entity
      rescue ActiveRecord::RecordInvalid => e
        render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Post not found." }, status: :not_found
      end

      def bulk_create
        ratings_attributes = params.require(:ratings).map do |r|
          r.permit(:post_id, :user_id, :value).to_h
        end

        Rating.insert_all(ratings_attributes, unique_by: %i[user_id post_id])

        post_ids = ratings_attributes.map { |r| r[:post_id] }.uniq

        # More efficient way to update average ratings for multiple posts
        Post.where(id: post_ids).update_all(
          "avg_rating = (SELECT AVG(value) FROM ratings WHERE ratings.post_id = posts.id)"
        )

        render json: { status: "created" }, status: :created
      rescue StandardError => e
        render json: { errors: e.message }, status: :unprocessable_entity
      end

      private

      def rating_params
        params.require(:rating).permit(:post_id, :user_id, :value)
      end

      def update_average_rating(post)
        # This calculation is safe from race conditions inside the transaction
        new_average = post.ratings.average(:value)
        post.update_column(:avg_rating, new_average)
      end
    end
  end
end
