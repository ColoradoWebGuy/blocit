class Post < ActiveRecord::Base
  belongs_to :topic
  belongs_to :user
  has_many :comments, dependent: :destroy
  has_many :labelings, as: :labelable
  has_many :labels, through: :labelings
  has_many :votes, dependent: :destroy
  has_many :favorites, dependent: :destroy

  default_scope { order('created_at DESC') }

  validates :title, length: { minimum: 5 }, presence: true
  validates :body, length: { minimum: 20 }, presence: true
  validates :topic, presence: true
  validates :user, presence: true

  after_create :create_fav

  def up_votes
     votes.where(value: 1).count
  end

  def down_votes
     votes.where(value: -1).count
  end

  def points
     votes.sum(:value)
  end

  def update_rank
     age_in_days = (created_at - Time.new(1970,1,1)) / 1.day.seconds
     new_rank = points + age_in_days
     update_attribute(:rank, new_rank)
  end

  private
  def create_fav
    # create a favorite for the new post
    user.favorites.create!(post: self)
    # send email
    FavoriteMailer.new_post(user, self).deliver_now
  end

end
