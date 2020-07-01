class FollowersController < ApplicationController
  def index
    @title = t "relationships.followers"
    @user = User.find_by id: params[:id]
    @users = @user.followers.page params[:page]
    render "users/show_follow"
  end
end
