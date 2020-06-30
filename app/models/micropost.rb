class Micropost < ApplicationRecord
  belongs_to :user

  validates :user_id, presence: true
  validates :content, presence: true, length: {maximum: Settings.micropost.content_max_length}
  validates :image, content_type: {in: %w[image/jpeg image/gif image/png], message: I18n.t("microposts.valid_image_format!")},
            size: {less_than: 5.megabytes, message: I18n.t("microposts.valid_image_size!")}

  scope :recent_posts, -> { order created_at: :desc }

  has_one_attached :image

  def display_image
    image.variant resize_to_limit: [Settings.micropost.image_max_size, Settings.micropost.image_max_size]
  end
end
