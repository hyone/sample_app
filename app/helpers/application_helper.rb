module ApplicationHelper
  def full_title(*titles)
    base_title = 'Ruby on Rails Tutorial Sample App'
    (titles << base_title).reject(&:nil?).join(' | ')
  end
end
