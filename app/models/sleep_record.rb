class SleepRecord < ApplicationRecord
  belongs_to :user

  validates :start_time, presence: true
  validate :end_after_start

  before_save :compute_duration_seconds, if: -> { end_time_changed? && end_time.present? }

  scope :finished, -> { where.not(end_time: nil) }


  def duration_seconds
    self[:duration_seconds] || (end_time && start_time && (end_time - start_time).to_i)
  end

  def clock_out!(end_time = Time.current)
    update!(
      end_time: end_time,
      duration_seconds: (end_time - start_time).to_i
    )
  end

  private

  def end_after_start
    return if end_time.blank? || start_time.blank?
    errors.add(:end_time, "must be after start_time") if end_time <= start_time
  end

  def compute_duration_seconds
    if end_time && start_time
      self.duration_seconds = (end_time - start_time).to_i
    end
  end
end
