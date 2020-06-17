class ApplicationController < ActionController::Base
  before_action :set_locale

  private
  def default_url_options
    {locale: I18n.locale}
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
end
