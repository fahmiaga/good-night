class Api::SleepRecordsController < ApplicationController
  before_action :set_sleep_record, only: [ :show, :clock_out ]

  def index
    page     = (params[:page] || 1).to_i
    per_page = [ (params[:per_page] || 50).to_i, 200 ].min
    offset   = (page - 1) * per_page

    cache_key = "user:#{current_user.id}:sleep_records:page#{page}:per#{per_page}"
    records_data = Rails.cache.fetch(cache_key, expires_in: 5.minutes) do
      records = current_user.sleep_records
                  .order(created_at: :desc)
                  .limit(per_page + 1)
                  .offset(offset)

      has_more = records.size > per_page
      records = records.first(per_page)

      {
        pagination: {
          page: page,
          per_page: per_page,
          has_more: has_more
        },
        records: records.map { |r| SleepRecordSerializer.new(r).as_json }
      }
    end

    render json: records_data
  end


  def create
    if current_user.sleep_records.where(end_time: nil).exists?
      return render json: { errors: [ "Already clocked in" ] }, status: :unprocessable_content
    end

    record = current_user.sleep_records.create!(
      start_time: create_params[:start_time] || Time.current
    )
    render json: SleepRecordSerializer.new(record).as_json, status: :created
  end

  def show
    render json: SleepRecordSerializer.new(@sleep_record).as_json
  end

  def clock_out
    @sleep_record.with_lock do
      if @sleep_record.end_time.present?
        return render json: { errors: [ "Already clocked out" ] }, status: :unprocessable_content
      end

      @sleep_record.clock_out!(clock_out_params[:end_time] || Time.current)
      render json: SleepRecordSerializer.new(@sleep_record).as_json
    end
  rescue ActiveRecord::RecordInvalid => e
    render json: { errors: e.record.errors.full_messages }, status: :unprocessable_content
  end

  private

  def create_params
    params.permit(:start_time)
  end

  def clock_out_params
    params.permit(:end_time)
  end

  def set_sleep_record
    @sleep_record = current_user.sleep_records.find(params[:id])
  end
end
