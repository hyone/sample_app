module ApplicationHelper
  def full_title(*titles)
    base_title = 'Ruby on Rails Tutorial Sample App'
    titles.unshift(base_title).reject(&:nil?).join(' | ')
  end
end
