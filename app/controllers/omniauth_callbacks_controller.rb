# frozen_string_literal: true

class OmniauthCallbacksController < ApplicationController
  def login_dot_gov
    omniauth_data = request.env['omniauth.auth']
    unless omniauth_data
      flash.alert= 'no omniauth data'
      redirect_to('/login')
      return
    end

    puts "omniauth_data:"
    omniauth_data.each do |k,v|
      if [:info, :credentials, :extra].include?(k.to_sym)
        puts "  #{k}"
        v.each do |k,v|
          puts "    #{k}: #{v}"
        end
      else
        puts "  #{k}: #{v}"
      end
    end

    credentials = omniauth_data['credentials']
    unless credentials
      flash.alert= 'no user credentials'
      redirect_to('/login')
      return
    end

    user = User.from_omniauth(omniauth_data)

    unless user
      flash.alert= 'no user'
      redirect_to('/login')
      return
    end

    unless user.login_allowed?
      # ToDo: Can we not use a string literal here? Also, where is this page, anyway?
      flash.alert= 'login not allowed for user'
      redirect_to('/login')
      return
    end

    reset_session
    set_user_session(user)
    session[:id_token]= credentials['id_token']

    # DEBUG
    puts "credentials['id_token']: #{credentials['id_token'].inspect}"
    puts "session[:id_token]: #{session[:id_token].inspect}"

    redirect_to(admin_home_page_path)
  end

  def set_user_session(user)
    user_session = UserSession.create(user)
    user_session.secure = Rails.application.config.ssl_options[:secure_cookies]
  end
end
