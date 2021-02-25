#frozen_string_literal: true

require 'spec_helper'

describe 'The landing page for GET login_dot_gov' do
  ACCESS_DENIED_TEXT= 'Access Denied'

  let(:first_affiliate) do
    Affiliate.create(website: 'https://first-affiliate.gov',
                     display_name: 'First Affiliate',
                     name: 'first')
  end

  let(:second_affiliate) do
    Affiliate.create(website: 'https://second-affiliate.gov',
                     display_name: 'Second Affiliate',
                     name: 'second')
  end

  let(:user_approval_status) { 'approved' }
  let(:user_first_name) { 'firstname' }
  let(:user_last_name) { 'lastname' }
  let(:user_organization_name) { 'organization' }
  let(:user_affiliates) { [] }
  let(:user_default_affiliate) { nil }
  let(:user_is_super_admin) { false }

  let(:user) do
    user = User.create(
      email: 'fake.user@test.org',
      first_name: user_first_name,
      last_name: user_last_name,
      organization_name: user_organization_name,
      approval_status: user_approval_status,
      is_affiliate_admin: user_is_super_admin
    )

    user.inviter = user
    user.approval_status = user_approval_status
    user.affiliates = user_affiliates
    user.default_affiliate = user_default_affiliate
    user.save!

    user
  end

  before do
    # DEBUG
    # Tracer.add_filter do |event, file, line, id, binding, klass, *rest|
    #   /^\/home\/jmax\/search-gov/ =~ file
    # end

    # Tracer.on do
    login(user) if user
    # end
  end

  describe 'when the user logged in without an explicit destination' do
    before { visit login_path }

    describe 'and omniauth failed to authenticate them' do
      let(:user) { nil }

      it 'is the security warning page' do
        expect(page).to have_current_path(login_path, ignore_query: true)
      end

      it 'has a flash message about the user not being approved' do
        expect(page).to have_text(ACCESS_DENIED_TEXT)
      end
    end

    describe 'and the user is not approved' do
      let(:user_approval_status) { 'not_approved' }

      it 'is the security warning page' do
        expect(page).to have_current_path(login_path, ignore_query: true)
      end

      it 'has a flash message about the user not being approved' do
        expect(page).to have_text(ACCESS_DENIED_TEXT)
      end
    end

    describe 'and the user is pending approval' do
      let(:user_approval_status) { 'pending_approval' }

      it 'is the users account page' do
        expect(page).to have_current_path(edit_account_path, ignore_query: true)
      end
    end

    describe 'and the user is not complete because missing a first name' do
      let(:user_first_name) { nil }

      it 'is the users account page' do
        expect(page).to have_current_path(edit_account_path, ignore_query: true)
      end
    end

    describe 'and the user is not complete because missing a last name' do
      let(:user_last_name) { nil }

      it 'is the users account page' do
        expect(page).to have_current_path(edit_account_path, ignore_query: true)
      end
    end

    describe 'and the user is not complete because missing an organization name' do
      let(:user_organization_name) { nil }

      it 'is the users account page' do
        expect(page).to have_current_path(edit_account_path, ignore_query: true)
      end
    end

    describe 'and the user is not associated with any affiliates' do
      let(:user_affiliates) { [] }

      it 'is the new site page' do
        expect(page).to have_current_path(new_site_path, ignore_query: true)
      end
    end

    describe 'and the user is a member of at least one affiliate' do
      let(:user_affiliates) { [first_affiliate, second_affiliate] }

      it 'is the first affiliate the user is a member of' do
        expect(page).to have_current_path(site_path(first_affiliate), ignore_query: true)
      end
    end

    describe 'and the user has a default affiliate' do
      let(:user_affiliates) { [first_affiliate, second_affiliate] }
      let(:user_default_affiliate) { second_affiliate }

      it 'is the default affiliate' do
        expect(page).to have_current_path(site_path(user_default_affiliate), ignore_query: true)
      end
    end

    describe 'and the user is a super admin' do
      let(:user_is_super_admin) { true }

      it 'is the admin page' do
        expect(page).to have_current_path(admin_home_page_path, ignore_query: true)
      end
    end
  end

  describe 'when the user logged in with an explicit destination' do
    let(:user_is_super_admin) { true }
    let(:explicit_destination) { '/admin/sayt_filters' }
    let(:path) { "#{login_path}?return_to=#{explicit_destination}" }

    before { visit path }

    describe 'and omniauth failed to authenticate them' do
      let(:user) { nil }

      it 'is the security warning page' do
        expect(page).to have_current_path(login_path, ignore_query: true)
      end

      it 'has a flash message about the user not being approved' do
        expect(page).to have_text(ACCESS_DENIED_TEXT)
      end
    end

    describe 'and the user is not approved' do
      let(:user_approval_status) { 'not_approved' }

      it 'is the security warning page' do
        expect(page).to have_current_path(login_path, ignore_query: true)
      end
    end

    describe 'and the user is pending approval' do
      let(:user_approval_status) { 'pending_approval' }

      it 'is the users account page' do
        expect(page).to have_current_path(edit_account_path, ignore_query: true)
      end
    end

    describe 'and the user is not complete because missing a first name' do
      let(:user_first_name) { nil }

      it 'is the users account page' do
        expect(page).to have_current_path(edit_account_path, ignore_query: true)
      end
    end

    describe 'and the user is not complete because missing a last name' do
      let(:user_last_name) { nil }

      it 'is the users account page' do
        expect(page).to have_current_path(edit_account_path, ignore_query: true)
      end
    end

    describe 'and the user is not complete because missing an organization name' do
      let(:user_organization_name) { nil }

      it 'is the users account page' do
        expect(page).to have_current_path(edit_account_path, ignore_query: true)
      end
    end

    describe 'and the user is not associated with any affiliates' do
      let(:user_affiliates) { [] }

      it 'is the explicit destination' do
        expect(page).to have_current_path(explicit_destination)
      end
    end

    describe 'and the user is a member of at least one affiliate' do
      let(:user_affiliates) { [first_affiliate, second_affiliate] }

      it 'is the explicit destination' do
        expect(page).to have_current_path(explicit_destination)
      end
    end

    describe 'and the user has a default affiliate' do
      let(:user_affiliates) { [first_affiliate, second_affiliate] }
      let(:user_default_affiliate) { second_affiliate }

      it 'is the explicit destination' do
        expect(page).to have_current_path(explicit_destination)
      end
    end

    describe 'and the user is a super admin' do
      let(:user_is_super_admin) { true }

      it 'is the explicit destination' do
        expect(page).to have_current_path(explicit_destination )
      end
    end
  end
end
