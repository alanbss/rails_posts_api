module Api
  module V1
    class IpAnalysisController < ApplicationController
      def index
        multi_author_ips = Post
          .joins(:user)
          .group(:ip)
          .having("COUNT(DISTINCT posts.user_id) > 1")
          .pluck(:ip, Arel.sql("ARRAY_AGG(DISTINCT users.login)"))

        response = multi_author_ips.map do |ip, logins|
          { ip: ip, logins: logins } # [cite: 32]
        end

        render json: response
      end
    end
  end
end
