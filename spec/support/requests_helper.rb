module RequestsHelper
  def signin(user, no_capybara: false)
    if no_capybara
      remember_token = User.new_remember_token
      cookies[:remember_token] = remember_token
      user.update_attribute(:remember_token, User.encrypt(remember_token))
    else
      visit signin_path
      fill_signin_form(user)
      click_signin_button
    end
  end

  def fill_signin_form(user)
    fill_in 'Email',    with: user.email
    fill_in 'Password', with: user.password
  end

  def click_signin_button
    click_button 'Sign in'
  end


  def signup(user)
    visit signup_path
    fill_userinfo_form(user)
    click_signup_button
  end

  def invalid_signup()
    visit signup_path
    click_signup_button
  end

  def fill_userinfo_form(user)
    fill_in 'Name',         with: user.name
    fill_in 'Email',        with: user.email
    fill_in 'Password',     with: user.password
    fill_in 'Confirmation', with: user.password_confirmation
  end

  def click_signup_button
    click_button 'Create my account'
  end
end
