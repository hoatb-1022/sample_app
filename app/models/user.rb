class User < ApplicationRecord
  # List of attributes will be permitted
  PERMIT_ATTRIBUTES = %i(name email password password_confirmation)

  attr_accessor :remember_token, :activation_token, :reset_token

  has_many :microposts, dependent: :destroy
  has_many :active_relationships, class_name: Relationship.name, foreign_key: :follower_id, dependent: :destroy
  has_many :passive_relationships, class_name: Relationship.name, foreign_key: :followed_id, dependent: :destroy
  has_many :following, through: :active_relationships, source: :followed
  has_many :followers, through: :passive_relationships, source: :follower

  validates :name, presence: true
  validates :email,
            presence: true,
            length: {maximum: Settings.user.email.max_length},
            format: {with: URI::MailTo::EMAIL_REGEXP},
            uniqueness: true
  validates :password, presence: true, length: {minimum: Settings.user.password.min_length}, allow_nil: true

  before_save :downcase_email
  before_create :create_activation_digest

  has_secure_password
  paginates_per Settings.user.per_page

  # Returns true if the given token matches the digest.
  def authenticated? attribute, token
    digest = send "#{attribute}_digest"
    return false unless digest
    BCrypt::Password.new(digest).is_password? token
  end

  # Remember an user
  def remember
    self.remember_token = User.new_token
    update_attribute :remember_digest, User.digest(remember_token)
  end

  # Forget an user.
  def forget
    update_attribute :remember_digest, nil
  end

  # Activates an account.
  def activate
    update_attributes activated: true, activated_at: Time.zone.now
  end

  # Sends activation email.
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  # Create reset password digest
  def create_reset_digest
    self.reset_token = User.new_token
    update_attributes reset_digest: User.digest(reset_token), reset_sent_at: Time.zone.now
  end

  # Send reset password email
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  def feed
    Micropost.feed_user following_ids << id
  end

  def follow other_user
    following << other_user
  end

  def unfollow other_user
    following.delete other_user
  end

  def following? other_user
    following.include? other_user
  end

  class << self
    # Returns the hash digest of the given string.
    def digest string
      cost = if ActiveModel::SecurePassword.min_cost
               BCrypt::Engine::MIN_COST
             else
               BCrypt::Engine.cost
             end
      BCrypt::Password.create string, cost: cost
    end

    # Generate new token
    def new_token
      SecureRandom.urlsafe_base64
    end
  end

  private

  # Downcase user's email
  def downcase_email
    self.email.downcase!
  end

  # Creates and assigns the activation token and digest.
  def create_activation_digest
    self.activation_token = User.new_token
    self.activation_digest = User.digest activation_token
  end
end
