class User < ApplicationRecord
  # List of attributes will be permitted
  PERMIT_ATTRIBUTES = %i(name email password password_confirmation)

  before_save :downcase_email

  validates :name, presence: true
  validates :email,
            presence: true,
            length: {maximum: Settings.user.email.max_length},
            format: {with: URI::MailTo::EMAIL_REGEXP},
            uniqueness: true
  validates :password, presence: true, length: {minimum: Settings.user.password.min_length}

  has_secure_password

  class << self
    # Returns the hash digest of the given string.
    def digest string
      cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
      BCrypt::Password.create string, cost: cost
    end
  end

  private

  def downcase_email
    self.email.downcase!
  end
end
