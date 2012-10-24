module App
  class Main < Sinatra::Base
    include WardenHelpers
    include FlashHelper
    # enable :sessions
    # set :session_secret, "agoodportfolio"
    set :root, File.dirname(__FILE__)
    set :public_folder, File.dirname(__FILE__) + "/public"

          
### home ###
    
    get "/" do
      erb :home
    end
    
### login / logout ### 
    
    get '/login/?' do
      redirect "/" if logged_in?
      erb :login
    end
    
    get '/logout/?' do
      warden.logout
      redirect '/'
    end
    
    post '/login/?' do
      warden.authenticate!
      redirect '/login'
    end
    
    post '/unauthenticated/?' do
      status 401
      erb :login
    end
    
### upgrade / signup ###
    
    get "/upgrade/?" do
      redirect "/pricing"
    end
    
    get "/upgrade/:plan/?" do
      @plan = Plan.retrieve(params[:plan])
      @user = User.new
      erb :upgrade
    end
    
    post "/upgrade/:plan/?" do
      # get the credit card details submitted by the form
      token = params[:stripeToken]
      coupon = params[:coupon]
      @user = User.new(params[:user])
      if @user.save && @user.create_subscription(token, coupon)
        warden.set_user @user
        redirect "/"
      else
        erb :upgrade
      end
    end
    
### pages ###

    get "/settings/?" do
      @user = current_user
      erb :settings
    end
    
    post "/settings/?" do
      @user = current_user
      if @user.update_attributes(params[:user])
        flash[:notice] = 'Saved. Good work.'
        redirect "/settings"
      else
        flash[:error] = 'Uh-oh, something went wrong. Try that again?'
        erb :settings
      end
    end
    
    get "/pricing/?" do
      erb :pricing
    end
    
    get "/about/?" do
      erb :about
    end
    
    # set :environment, :production
    # error do
    #   content_type :json
    #   status 500 # or whatever
    # 
    #   e = env['sinatra.error']
    #   {:result => 'error', :message => e.message}.to_json
    # end
    
  end
end