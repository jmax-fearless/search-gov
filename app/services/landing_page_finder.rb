# frozen_string_literal: true

class LandingPageFinder
  include Rails.application.routes.url_helpers

  def initialize(user, return_to)
    @user = user
    @return_to = return_to
  end

  def landing_page
    (@user.approval_status == 'pending_approval' && edit_account_path) ||
      (!@user.complete? && edit_account_path) ||
      @return_to ||
      (@user.is_affiliate_admin? && admin_home_page_path) ||
      (@user.is_affiliate? && @user.default_affiliate && site_path(@user.default_affiliate)) ||
      (@user.is_affiliate? && !@user.affiliates.empty? && site_path(@user.affiliates.first)) ||
      new_site_path
  end
end
