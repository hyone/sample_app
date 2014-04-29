class UsersController < ApplicationController
  before_action :require_signin_user,      only: [:index, :edit, :update, :destroy]
  before_action :require_correct_user,     only: [:edit, :update]
  before_action :require_admin_user,       only: [:destroy]
  before_action :require_non_current_user, only: [:destroy]
  before_action :require_non_signin_user,  only: [:new, :create]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      signin @user
      flash[:success] = 'Welcome to the Sample App!'
      redirect_to @user
    else
      render 'new'
    end
  end

  def index
    @users = User.paginate(page: params[:page], per_page: 30)
  end

  def show
    @user = User.find(params[:id])
    @microposts = @user.microposts.paginate(page: params[:page])
  end

  def edit
  end

  def update
    if @user.update_attributes(user_params)
      flash[:success] = 'Profile updated'
      redirect_to @user
    else
      render 'edit'
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = 'User deleted.'
    redirect_to users_url
  end

  private
  def user_params
    params.require(:user).permit(
      :name, :email, :password, :password_confirmation
    )
  end

  # Before actions

  def require_correct_user
    @user = User.find(params[:id])
    redirect_to(root_path) unless current_user?(@user)
  end

  def require_non_current_user
    @user = User.find(params[:id])
    redirect_to(root_path) if current_user?(@user)
  end

  def require_admin_user
    redirect_to(root_path) unless current_user.admin?
  end

  def require_non_signin_user
    redirect_to(root_path) if signin?
  end
end
