RSpec::Matchers.define :have_message do |kind, message|
  match do |page|
    expect(page).to have_selector("div.alert.alert-#{kind}", text: message)
  end
end


module RequestSpecHelper
  def valid_signin(user)
    fill_in 'Email',    with: user.email
    fill_in 'Password', with: user.password
    click_button 'Sign in'
  end


  def signup
    click_button 'Create my account'
  end

  def valid_signup(user)
    fill_in 'Name',         with: user.name
    fill_in 'Email',        with: user.email
    fill_in 'Password',     with: user.password
    fill_in 'Confirmation', with: user.password_confirmation
    signup
  end

  def invalid_signup()
    signup
  end
end
