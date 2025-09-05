class Api::UsersController < ApplicationController
  before_action :set_user, only: [ :follow, :show, :unfollow ]


  def show
   since = params[:since].present? ? Time.parse(params[:since]) : 7.days.ago
   until_time = params[:until].present? ? Time.parse(params[:until]) : Time.current

   friend_ids = current_user.followings.pluck(:id)

   records = SleepRecord
    .where(user_id: friend_ids)
    .where("start_time >= ? AND start_time <= ?", since, until_time)
    .where.not(end_time: nil)
    .order(duration_seconds: :desc)
    .includes(:user)
    .limit(500)

   grouped = records.group_by(&:user)

   render json: {
     since: since,
     until: until_time,
     users: grouped.map do |user, recs|
       {
         id: user.id,
         name: user.name,
         records: recs.map do |r|
           {
             id: r.id,
             start_time: r.start_time,
             end_time: r.end_time,
             duration_seconds: r.duration_seconds
           }
        end
       }
     end
   }
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
      render json: { error: follow.errors.full_messages }, status: :unprocessable_entity
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
