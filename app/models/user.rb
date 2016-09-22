class User < ActiveRecord::Base
  APPROVAL_STATUSES = %w( pending_email_verification pending_approval approved not_approved )
  PASSWORD_FORMAT = /\A
    (?=.{8,}\z)        # Must contain 8 or more characters
    (?=.*\d)           # Must contain a digit
    (?=.*[a-zA-Z])     # Must contain a letter
    (?=.*[[:^alnum:]]) # Must contain a symbol
  /x

  validates_presence_of :email
  validates_presence_of :contact_name
  validates_inclusion_of :approval_status, :in => APPROVAL_STATUSES
  validates_format_of :password,
    with: PASSWORD_FORMAT,
    if: :require_password?,
    message: 'must include a combination of letters, numbers, and special characters.'
  has_many :memberships, :dependent => :destroy
  has_many :affiliates, :order => 'affiliates.display_name, affiliates.ID ASC', through: :memberships
  has_many :watchers, dependent: :destroy
  belongs_to :default_affiliate, class_name: 'Affiliate'
  before_validation :downcase_email
  before_validation :set_initial_approval_status, :on => :create
  after_validation :set_default_flags, :on => :create

  with_options if: :is_pending_email_verification? do
    after_create :deliver_email_verification
  end

  before_update :detect_deliver_welcome_email
  after_create :ping_admin
  after_update :deliver_welcome_email
  after_save :push_to_nutshell
  attr_accessor :invited, :skip_welcome_email, :inviter, :require_password
  scope :approved_affiliate, where(:is_affiliate => true, :approval_status => 'approved')
  scope :not_approved, where(approval_status: 'not_approved')
  scope :approved_with_same_nutshell_contact, lambda { |user| { conditions: { nutshell_id: user.nutshell_id, approval_status: 'approved' } } }

  acts_as_authentic do |c|
    c.crypto_provider = Authlogic::CryptoProviders::BCrypt
    c.perishable_token_valid_for 1.hour
    c.disable_perishable_token_maintenance(true)
    c.require_password_confirmation = false
  end

  APPROVAL_STATUSES.each do |status|
    define_method "is_#{status}?" do
      approval_status == status
    end

    define_method "set_approval_status_to_#{status}" do
      self.approval_status = status
    end
  end

  def deliver_password_reset_instructions!
    reset_perishable_token!
    MandrillUserEmailer.new(self).send_password_reset_instructions
  end

  def to_label
    "#{contact_name} <#{email}>"
  end

  def is_affiliate_or_higher
    is_affiliate || is_affiliate_admin
  end

  def is_developer?
    !is_affiliate_or_higher
  end

  def has_government_affiliated_email?
    email =~ /\.(gov|mil|fed\.us)$|(\.|@)state\.[a-z]{2}\.us$/i
  end

  #authlogic magic state
  def approved?
    approval_status != 'not_approved'
  end

  def verify_email(token)
    return true if is_approved?
    if is_pending_email_verification? and email_verification_token == token
      if requires_manual_approval?
        set_approval_status_to_pending_approval
      else
        set_approval_status_to_approved
        self.welcome_email_sent = true
      end

      self.email_verification_token = nil
      save!
      send_welcome_to_new_user_email if is_approved?
      true
    else
      false
    end
  end

  def complete_registration(attributes)
    self.require_password = true
    self.email_verification_token = nil
    self.set_approval_status_to_approved
    !self.requires_manual_approval? and self.update_attributes(attributes)
  end

  def self.new_invited_by_affiliate(inviter, affiliate, attributes)
    new_user = User.new(attributes)
    new_user.password = SecureRandom.hex(10) + "MLPFTW2016!!!"
    new_user.inviter = inviter
    new_user.invited = true
    new_user.affiliates << affiliate
    new_user
  end

  def affiliate_names
    affiliates.collect(&:name).join(',')
  end

  def nutshell_approval_status
    if User.approved_with_same_nutshell_contact(self).count > 0
      'approved'
    else
      approval_status
    end
  end

  def send_new_affiliate_user_email(affiliate, inviter_user)
    MandrillUserEmailer.new(self).send_new_affiliate_user(affiliate, inviter_user)
  end

  def add_to_affiliate(affiliate, source)
    affiliate.users << self unless self.affiliates.include? affiliate
    NutshellAdapter.new.push_site affiliate
    audit_trail_user_added(affiliate, source)
  end

  def remove_from_affiliate(affiliate, source)
    Membership.where(user_id: self.id, affiliate_id: affiliate.id).destroy_all
    NutshellAdapter.new.push_site affiliate
    audit_trail_user_removed(affiliate, source)
  end

  private

  def require_password?
    require_password.nil? ? super : (require_password == true)
  end

  def ping_admin
    Emailer.new_user_to_admin(self).deliver
  end

  def deliver_email_verification
    assign_email_verification_token!
    invited ? deliver_welcome_to_new_user_added_by_affiliate : deliver_new_user_email_verification
  end

  def assign_email_verification_token!
    loop do
      begin
        update_attribute(:email_verification_token, Authlogic::Random.friendly_token.downcase)
        break
      rescue ActiveRecord::RecordNotUnique
      end
    end
  end

  def deliver_new_user_email_verification
    MandrillUserEmailer.new(self).send_new_user_email_verification
  end

  def deliver_welcome_to_new_user_added_by_affiliate
    MandrillUserEmailer.new(self).send_welcome_to_new_user_added_by_affiliate
  end

  def detect_deliver_welcome_email
    if is_approved? && !welcome_email_sent?
      self.welcome_email_sent = true
      @deliver_welcome_email_on_update = true
    else
      @deliver_welcome_email_on_update = false
    end
    true
  end

  def deliver_welcome_email
    send_welcome_to_new_user_email if @deliver_welcome_email_on_update
  end

  def set_initial_approval_status
    set_approval_status_to_pending_email_verification if self.approval_status.blank? or invited
  end

  def downcase_email
    self.email = self.email.downcase if self.email.present?
  end

  def set_default_flags
    self.requires_manual_approval = true if is_affiliate? and !has_government_affiliated_email? and !invited
    self.welcome_email_sent = true if (is_developer? and !skip_welcome_email)
  end

  def push_to_nutshell
    if contact_name_changed? || email_changed? || approval_status_changed?
      NutshellAdapter.new.push_user self
    end
  end

  def send_welcome_to_new_user_email
    MandrillUserEmailer.new(self).send_welcome_to_new_user
  end

  def audit_trail_user_added(site, source)
    add_nutshell_note_for_user('added', 'to', site, source)
  end

  def audit_trail_user_removed(site, source)
    add_nutshell_note_for_user('removed', 'from', site, source)
  end

  def add_nutshell_note_for_user(added_or_removed, to_or_from, site, source)
    note = "#{source} #{added_or_removed} @[Contacts:#{self.nutshell_id}], #{self.email} #{to_or_from} @[Leads:#{site.nutshell_id}] #{site.display_name} [#{site.name}]."
    NutshellAdapter.new.new_note(self, note)
  end
end
