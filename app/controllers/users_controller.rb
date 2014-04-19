class UsersController < ApplicationController
  before_action :signin_user,      only: [:index, :edit, :update, :destroy]
  before_action :correct_user,     only: [:edit, :update]
  before_action :admin_user,       only: [:destroy]
  before_action :non_current_user, only: [:destroy]
  before_action :non_signin_user,  only: [:new, :create]

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
  def signin_user
    unless signin?
      set_redirect_location
      redirect_to signin_url, notice: 'Please sign in.'
    end
  end

  def correct_user
    @user = User.find(params[:id])
    redirect_to(root_path) unless current_user?(@user)
  end

  def non_current_user
    @user = User.find(params[:id])
    redirect_to(root_path) if current_user?(@user)
  end

  def admin_user
    redirect_to(root_path) unless current_user.admin?
  end

  def non_signin_user
    redirect_to(root_path) if signin?
  end
end
