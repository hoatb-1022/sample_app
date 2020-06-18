class UsersController < ApplicationController
  before_action :check_login, only: :show
  def index; end

  def show
    @user = User.find_by id: params[:id]

    return if @user
    flash[:danger] = t ".not_found"
    redirect_to root_url
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new user_params

    if @user.save
      flash[:success] = t "static_pages.home.welcome"
      log_in @user
      redirect_to @user
    else
      flash.now[:danger] = t ".new.failed_create_account"
      render :new
    end
  end

  private

  def user_params
    params.require(:user).permit User::PERMIT_ATTRIBUTES
  end

  def check_login
    return if logged_in?
    flash[:danger] = t ".show.login_to_see"
    redirect_to root_url
  end
end
