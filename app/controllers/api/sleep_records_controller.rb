class Api::SleepRecordsController < ApplicationController
  before_action :set_sleep_record, only: [ :show, :clock_out ]

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

  def show
    render json: @sleep_record.as_json(
      only: [ :id, :user_id, :start_time, :end_time, :duration_seconds ],
      include: {
        user: { only: [ :id, :name ] }
      }
    )
  end

  def clock_out
    end_time = clock_out_params[:end_time] || Time.current

    SleepRecord.transaction do
      @sleep_record.lock!

      if @sleep_record.end_time.present?
        render json: { error: "Already clocked out" }, status: :unprocessable_entity and return
      end

      @sleep_record.end_time = end_time
      @sleep_record.duration_seconds = (end_time - @sleep_record.start_time).to_i

      if @sleep_record.save
        render json: @sleep_record.as_json(
          only: [ :id, :user_id, :start_time, :end_time, :duration_seconds ],
          include: {
            user: { only: [ :id, :name ] }
          }
          )
      else
        render json: { error: @sleep_record.errors.full_messages }, status: :unprocessable_entity
      end
    end
  end

private
  def create_params
    params.permit(:start_time)
  end

  def set_sleep_record
    @sleep_record = current_user.sleep_records.find(params[:id])
  end

  def clock_out_params
    params.permit(:end_time)
  end
end
