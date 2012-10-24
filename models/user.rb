class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include BCrypt
  
  attr_accessor         :password
  attr_protected        :password_hash
  
  field :name
  field :email
  field :password_hash
  field :admin
  field :customer_id
  
  validates_presence_of :name, :message => "We'd like to know what to call you."
  validates_presence_of :password, :message => "Passwords are necessary, we want your info secure.", :on => :create
  validates_presence_of :email, :message => "We need your email for login & to email you stuff."
  validates_uniqueness_of :email, :message => "Email account is already registered."
  
  belongs_to :account
  
  before_save :encrypt_password
  
  def self.authenticate(email, password)
    return "email" if email.empty?
    return "password" if password.empty?
    @user = User.where(:email => email)
    return 'email' if @user.empty?                            # someone is up to no good, we did not even find their email address 
    @password = BCrypt::Password.new(@user.first.password_hash)    # at least we found a user with an email address, so let's check their password now... 
    @password == password ? @user.first : 'password'          # if the password was found to be good, we can return the user object we found by email address
  end
  
  def encrypt_password
  	 self.password_hash = Password.create(@password)
  end
  
  
  def self.get(id)
    User.find(id)
  end
  
  ## subscription stuff
  
  def create_subscription(token, coupon = nil)
    # create a Customer
    c = Stripe::Customer.create(
      :card => token,
      :plan => self.plan,
      :email => self.email,
      :description => self.name,
      :coupon => coupon
    )
    self.customer_id = c.id
  end
  
  def update_subscription(plan, card=nil, coupon = nil)
    customer.update_subscription(
      :prorate => true, 
      :card => card,
      :coupon => coupon,
      :plan => plan
    )
  end
  
  def cancel_subscription
    customer.cancel_subscription
  end
  
  def customer
    @customer ||= Stripe::Customer.retrieve(self.customer_id)
  end
  
  def delete_customer
    customer.cancel_subscription
    customer.delete
  end
  
end