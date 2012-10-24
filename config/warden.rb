# warden
Warden::Manager.serialize_into_session{|user| user.id }
Warden::Manager.serialize_from_session{|id| User.get(id) }

Warden::Manager.before_failure do |env,opts|
  env['REQUEST_METHOD'] = "POST"
end

Warden::Strategies.add(:password) do

  def valid?
    params["email"] || params["password"]
  end

  def authenticate!
    user = User.authenticate(params["email"], params["password"])
    unless user.instance_of?(User)
      case user   # we failed to find a User account.. let's try and see why
        when 'email'
          if params["email"].empty?
            fail!("Oops, you forgot to type in an email.")
          else
            fail!("That email doesn't seem to be registered.<br/> Are you sure that's the right one?")
          end
        when 'password'
          if params["password"].empty?
            fail!("You forgot to enter a password! Try that again.")
          else
            fail!("That account has a different password than the one you entered. <a href='mailto:hello@aapp.com?Subject=I%20forgot%20my%20password%20%3A-%28&Body=Hey%2C%20I%20can%27t%20seem%20to%20log%20in%2C%20it%20keeps%20telling%20me%20my%20password%20is%20wrong.%20Can%20you%20reset%20it%20for%20me%3F'>Did you forget it?</a>")
          end
      end  
    else
      env['warden'].set_user(user, :scope => :admin) if user.admin == true
      success!(user)
    end
    
  end
end

### helpers ###

module WardenHelpers
        
  def warden
    env['warden']
  end
  
  def current_user
    warden.user
  end
  
  def logged_in?
    warden.authenticated? || warden.authenticated?(:admin)
  end
  
end