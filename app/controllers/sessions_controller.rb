class SessionsController < ApplicationController
  def new; end

  def create
    @user = User.find_by email: params[:session][:email].downcase

    if @user&.authenticate params[:session][:password]
      if @user.activated?
        log_in @user
        params[:session][:remember_me] == Settings.session.remember_me? ? remember(@user) : forget(@user)
        redirect_back_or @user
      else
        flash[:warning] = t ".check_active_mail"
        redirect_to root_url
      end
    else
      flash.now[:danger] = t "erors.invalid_email_password_combination"
      render :new
    end
  end

  def destroy
    log_out
    redirect_to root_url
  end
end
