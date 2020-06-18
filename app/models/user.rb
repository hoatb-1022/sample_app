class User < ApplicationRecord
  # List of attributes will be permitted
  PERMIT_ATTRIBUTES = %i(name email password password_confirmation)

  attr_accessor :remember_token
  before_save :downcase_email

  validates :name, presence: true
  validates :email,
            presence: true,
            length: {maximum: Settings.user.email.max_length},
            format: {with: URI::MailTo::EMAIL_REGEXP},
            uniqueness: true
  validates :password, presence: true, length: {minimum: Settings.user.password.min_length}

  has_secure_password

  # Check if remembered token is correct password
  def authenticated? remember_token
    BCrypt::Password.new(remember_digest).is_password? remember_token
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
end
