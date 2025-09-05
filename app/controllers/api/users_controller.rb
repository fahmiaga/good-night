class Api::UsersController < ApplicationController
  before_action :set_user, only: [ :follow ]

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

  private

  def set_user
    @user = User.find(params[:user_id])
  end
end
