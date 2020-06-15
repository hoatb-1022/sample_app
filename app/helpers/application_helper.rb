module ApplicationHelper
  def full_title page_title
    base_title = t "global.rails-tut-app"
    page_title.blank? ? base_title : "#{page_title} | #{base_title}"
  end
end
