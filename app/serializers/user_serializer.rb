class UserSerializer
  def initialize(user, sleep_records)
    @user = user
    @sleep_records = sleep_records
  end

  def as_json(*)
    {
      id: @user.id,
      name: @user.name,
      records: @sleep_records.map do |r|
        {
          id: r.id,
          start_time: r.start_time,
          end_time: r.end_time,
          duration_seconds: r.duration_seconds
        }
      end
    }
  end
end
