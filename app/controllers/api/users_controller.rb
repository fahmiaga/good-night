class Api::UsersController < ApplicationController
  before_action :set_user, only: [ :follow, :show, :unfollow ]


  def show
    since = params[:since].present? ? Time.parse(params[:since]) : 7.days.ago
    until_time = params[:until].present? ? Time.parse(params[:until]) : Time.current
    page     = (params[:page] || 1).to_i
    per_page = [ (params[:per_page] || 50).to_i, 200 ].min
    offset   = (page - 1) * per_page

    cache_key = "user:#{current_user.id}:followings_sleep:#{since.to_i}:#{until_time.to_i}:page#{page}:per#{per_page}"
    response_data = Rails.cache.fetch(cache_key, expires_in: 5.minutes) do
      records = SleepRecord
                  .joins(user: :followers)
                  .where(follows: { follower_id: current_user.id })
                  .where("sleep_records.start_time >= ? AND sleep_records.start_time <= ?", since, until_time)
                  .where.not(sleep_records: { end_time: nil })
                  .order(duration_seconds: :desc)
                  .includes(:user)
                  .limit(per_page + 1)
                  .offset(offset)

      has_more = records.size > per_page
      records = records.first(per_page)
      grouped = records.group_by(&:user)

      {
        since: since,
        until: until_time,
        pagination: {
          page: page,
          per_page: per_page,
          has_more: has_more
        },
        users: grouped.map do |user, recs|
          UserSerializer.new(user, recs).as_json
        end
      }
    end

    render json: response_data
  end


  def follow
    follow = current_user.active_follows.build(followed: @user)
    if follow.save
      render json: follow.as_json(
      only: [ :id, :created_at ],
      include: {
        follower: { only: [ :id, :name ] },
        followed: { only: [ :id, :name ] }
      }
    ), status: :created
    else
      render json: { error: follow.errors.full_messages }, status: :unprocessable_content
    end
  end

  def unfollow
    followed = current_user.active_follows.find_by(follower_id: current_user.id, followed_id: @user.id)
    if followed
      followed.destroy
      render json: followed.as_json(
      only: [ :id, :created_at ],
      include: {
        followed: { only: [ :id, :name ] }
      }
    ), status: :ok
    else
      render json: { error: "Not following" }, status: :not_found
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end
end
