# frozen_string_literal: true

class UserSessionsController < ApplicationController
  before_action :require_user, only: :destroy

  def security_notification
    # DEBUG
    # puts "UserSessionsController#security_notification"
    # puts "    current_user: #{current_user.inspect}"

    # return unless current_user

    # DEBUG
    # puts "    current_user.login_allowed?: #{current_user.login_allowed?}"
    # puts "    current_user.is_pending_approval?: #{current_user.is_pending_approval?}"

    # unless current_user.login_allowed? || current_user.is_pending_approval?
    #   flash[:error] =
    #     'Access Denied: These credentials are not recognized as valid' \
    #     ' for accessing Search.gov. Please reach out to' \
    #     ' search@support.digitalgov.gov if you believe this is in error.'
    #   return
    # end

    finder = LandingPageFinder.new(current_user, params[:return_to])
    redirect_to(finder.landing_page)
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
