# frozen_string_literal: true

class OmniauthCallbacksController < ApplicationController
  class InternalLoginError < StandardError
  end

  def login_dot_gov
    try_to_login
  rescue LandingPageFinder::Error => e
    flash[:error] = e.message
    redirect_to('/login')
  rescue InternalLoginError => e
    flash[:error] = "login internal error: #{e.message}"
    redirect_to('/login')
  end

  def try_to_login
    @return_to = session[:return_to]
    reset_session
    set_id_token
    set_user_session
    redirect_to(destination)
  end

  def destination
    finder = LandingPageFinder.new(user, @return_to)
    finder.landing_page
  end

  def user
    @user ||= User.from_omniauth(omniauth_data)
    raise(LandingPageFinder::Error, LandingPageFinder::ACCESS_DENIED_TEXT) unless @user&.login_allowed? || @user&.is_pending_approval?

    @user
  end

  def omniauth_data
    raise InternalLoginError, 'no omniauth data' unless request.env['omniauth.auth']

    request.env['omniauth.auth']
  end

  def credentials
    raise InternalLoginError, 'no user credentials' unless omniauth_data['credentials']

    omniauth_data['credentials']
  end

  def set_id_token
    session[:id_token] = credentials['id_token']
  end

  def set_user_session
    user_session = UserSession.create(user)
    user_session.secure = Rails.application.config.ssl_options[:secure_cookies]
  end
end
