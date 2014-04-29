module Matchers
  signin_text  = 'Sign in'
  signout_text = 'Sign out'

  RSpec::Matchers.define :have_signin_link do
    match do |page|
      Capybara.string(page.body).has_link?(signin_text, href: signin_path)
    end

    description { 'have signin link' }
  end

  RSpec::Matchers.define :have_signout_link do
    match do |page|
      Capybara.string(page.body).has_link?(signout_text, href: signout_path)
    end

    description { 'have signout link' }
  end

  RSpec::Matchers.define :have_profile_link do |user|
    match do |page|
      Capybara.string(page.body).has_link?('Profile', href: user_path(user))
    end

    description { 'have user profile link' }
  end

  RSpec::Matchers.define :have_settings_link do |user|
    match do |page|
      Capybara.string(page.body).has_link?('Settings', href: edit_user_path(user))
    end

    description { 'have user settings link' }
  end

  RSpec::Matchers.define :have_message do |type, text = nil|
  match do |page|
    Capybara.string(page.body).has_selector?(
      "div.alert.alert-#{type}", text: text
    )
    # expect(page).to have_selector("div.alert.alert-#{type}", text: text)
  end

  description {
    "have #{type} message #{text ? "'#{text}'" : ''}"
  }
  end
end
