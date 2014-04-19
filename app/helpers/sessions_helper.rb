module SessionsHelper
  def signin(user)
    remember_token = User.new_remember_token
    cookies.permanent[:remember_token] = remember_token
    user.update_attribute(:remember_token, User.encrypt(remember_token))
    self.current_user = user
  end

  def signin?
    !current_user.nil?
  end

  def signout
    self.current_user = nil
    cookies.delete(:remember_token)
  end


  def current_user=(user)
    @current_user = user
  end

  def current_user
    unless @current_user
      remember_token = User.encrypt(cookies[:remember_token])
      @current_user  = User.find_by(remember_token: remember_token)
    end
    @current_user
  end

  def current_user?(user)
    user == current_user
  end


  def redirect_back_or(default)
    logger.info default
    logger.info "redirect: #{session[:return_to]}"
    redirect_to(session[:return_to] || default)
    session.delete(:return_to)
    logger.info "SESSION DELETED"
    logger.info "redirect: #{session[:return_to]}"
  end

  def set_redirect_location
    session[:return_to] = request.url
  end
end
