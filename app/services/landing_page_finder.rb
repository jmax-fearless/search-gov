# frozen_string_literal: true

class LandingPageFinder
  include Rails.application.routes.url_helpers

  ACCESS_DENIED_TEXT =
    'Access Denied: These credentials are not recognized as valid' \
    ' for accessing Search.gov. Please reach out to' \
    ' search@support.digitalgov.gov if you believe this is in error.'

  class Error < StandardError
  end

  def initialize(user, return_to)
    @user = user
    @return_to = return_to
  end

  def landing_page
    raise(Error, ACCESS_DENIED_TEXT) if !@user || @user.is_not_approved?

    return_value = destination_edit_account ||
      destination_original ||
      destination_affiliate_admin ||
      destination_site_page ||
      new_site_path

    # DEBUG
    # puts "LandingPageFinder#landing_page: returning #{return_value.inspect}"

    return_value
  end

  private

  def destination_edit_account
    return_value = (@user.approval_status == 'pending_approval' && edit_account_path) ||
                   (!@user.complete? && edit_account_path)

    # DEBUG
    # puts "LandingPageFinder#destination_edit_account: returning #{return_value.inspect}"
    # puts "    @user.approval_status: #{@user.approval_status.inspect}"
    # puts "    edit_account_path: #{edit_account_path.inspect}"
    # puts "    @user.complete?: #{@user.complete?.inspect}"

    return_value
  end

  def destination_original
    return_value = @return_to

    # DEBUG
    # puts "LandingPageFinder#destination_original: returning #{return_value.inspect}"
    # puts "    @return_to: #{@return_to.inspect}"

    return_value
  end

  def destination_affiliate_admin
    return_value = @user.is_affiliate_admin? && admin_home_page_path

    # DEBUG
    # puts "LandingPageFinder#destination_affiliate_admin: returning #{return_value.inspect}"
    # puts "    @user.is_affiliate_admin?: #{@user.is_affiliate_admin?.inspect}"

    return_value
  end

  def destination_site_page
    return_value = @user.is_affiliate? && affiliate_site_page

    # DEBUG
    # puts "LandingPageFinder#destination_site_page: returning #{return_value.inspect}"
    # puts "    @user.is_affiliate?: #{@user.is_affiliate?.inspect}"

    return_value
  end

  def affiliate_site_page
    return_value = if @user.default_affiliate
      site_path(@user.default_affiliate)
    elsif !@user.affiliates.empty?
      site_path(@user.affiliates.first)
    end

    # DEBUG
    # puts "LandingPageFinder#affiliate_site_page: returning #{return_value.inspect}"
    # puts "    @user.default_affiliate: #{@user.default_affiliate.inspect}"
    # puts "    @user.affiliates.first: #{(!@user.affiliates.empty? && @user.affiliates.first).inspect}"

    return_value
  end
end
