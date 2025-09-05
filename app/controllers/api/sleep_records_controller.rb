class Api::SleepRecordsController < ApplicationController
def index
  user =  current_user
  records = user.sleep_records.order(created_at: :desc).limit(100)
  render json: records.as_json(
    only: [ :id, :user_id, :start_time, :end_time, :duration_seconds, :created_at ],
    include: {
      user: { only: [ :id, :name ] }
    }
  )
end

def create
  record= current_user.sleep_records.create!(start_time: create_params[:start_time] || Time.current)
  render json: record.as_json(
    only: [ :id, :user_id, :start_time, :end_time, :duration_seconds, :created_at ],
    include: {
      user: { only: [ :id, :name ] }
    }
  ), status: :created
end

private
  def create_params
    params.permit(:start_time)
  end
end
