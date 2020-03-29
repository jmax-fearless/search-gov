# frozen_string_literal: true

class UserSessionsController < ApplicationController
  before_action :require_user, only: :destroy

  def security_notification
    redirect_to(account_path) if current_user && current_user&.complete?
  end

  def destroy
    id_token= session[:id_token]
    login_dot_gov_host= 'https://idp.int.identitysandbox.gov'
    login_dot_gov_logout_endpoint= '/openid_connect/logout'
    login_dot_gov_logout_url= "#{login_dot_gov_host}#{login_dot_gov_logout_endpoint}"

    # login_dot_gov_logout_url= 'https://idp.int.identitysandbox.gov/openid_connect/logout'
    # response= Faraday.get(
    #   login_dot_gov_logout_url,
    #   id_token_hint: id_token,
    #   post_logout_redirect_uri: 'http://localhost:3000/auth/logindotgov/callback',
    #   state: '1234567890123456789012'
    # )
    puts "id_token: #{id_token}"

    connection= Faraday.new(login_dot_gov_logout_url) do |faraday|
      faraday.request :url_encoded
      faraday.response :logger
      faraday.adapter Faraday.default_adapter
    end

    response= connection.get do |request|
      request.params['id_token_hint']=  id_token
      request.params['post_logout_redirect_uri']= 'http://localhost:3000/auth/logindotgov/callback'
      request.params['state']= '1234567890123456789012'
    end

    # DEBUG
    puts "response status: #{response.status}"
    puts "response body: #{response.body}"

    reset_session
    current_user_session.destroy
    redirect_to(login_path)
    # redirect_to('http://localhost:3000/auth/logindotgov/callback')
  end
end
