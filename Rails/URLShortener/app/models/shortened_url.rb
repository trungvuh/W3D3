require 'securerandom'

class ShortenedUrl < ApplicationRecord
  validates :long_url, :user_id, presence: true
  validates :short_url, presence: true, uniqueness: true

  # attr_accessor :short_url, :long_url
  # attr_reader :user_id

  def self.random_code
    while true
      random = SecureRandom.urlsafe_base64(16)
      return random unless ShortenedUrl.exists?(short_url: random)
    end
  end

  def self.create_short!(user, long_url)
    ShortenedUrl.create!(long_url: long_url, short_url: ShortenedUrl.random_code, user_id: user.id)
  end

  belongs_to :submitter,
    class_name: :User,
    primary_key: :id,
    foreign_key: :user_id

  has_many :visits,
    class_name: :visit,
    primary_key: :id,
    foreign_key: :shortened_url_id

  has_many :visitors,
    Proc.new { distinct },
    through: :visits,
    source: :visitor

  def num_clicks
    self.visits.count
  end

  def num_uniques
    self.visitors.count
  end

  def num_recent_uniques
    start = Time.now - 10.minutes.ago
    self.visitors.where("updated_at >= '#{start}'")
  end


end
