# frozen_string_literal: true

class UserSessionsController < ApplicationController
  before_action :require_user, only: :destroy

  def security_notification
    return unless current_user

    if current_user.login_allowed?
      finder = LandingPageFinder.new(current_user, params[:return_to])
      redirect_to(finder.landing_page)
    else
      flash[:error] = LandingPageFinder::ACCESS_DENIED_TEXT
    end
  rescue LandingPageFinder::Error => e
    flash[:error] = e.message
  end

  def destroy
    id_token = session[:id_token]
    reset_session
    current_user_session.destroy
    redirect_to(LoginDotGovSettings.logout_redirect_uri(id_token, login_uri))
  end

  def login_uri
    "#{request.protocol}#{request.host_with_port}/login"
  end
end
