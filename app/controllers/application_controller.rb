class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper

  before_action :set_locale

  private

  def default_url_options
    {locale: I18n.locale}.merge(super)
  end

  # Set locale for I18n
  def set_locale
    I18n.locale = extract_locale || I18n.default_locale
  end

  # Extract locale from URL
  def extract_locale
    parsed_locale = params[:locale]
    I18n.available_locales.map(&:to_s).include?(parsed_locale) ? parsed_locale : nil
  end

  def logged_in_user
    return if logged_in?
    store_location
    flash[:danger] = t "global.please_login"
    redirect_to login_url
  end
end
