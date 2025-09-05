class SleepRecordSerializer
  def initialize(record)
    @record = record
  end

  def as_json(*)
    {
      id: @record.id,
      user_id: @record.user_id,
      start_time: @record.start_time,
      end_time: @record.end_time,
      duration_seconds: @record.duration_seconds,
      created_at: @record.created_at,
      user: {
        id: @record.user.id,
        name: @record.user.name
      }
    }
  end
end
