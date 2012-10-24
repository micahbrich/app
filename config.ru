require 'rubygems'
require 'bundler'
Bundler.require(:default)

# database
Mongoid.load!('config/mongoid.yml')

# config & model files
Dir.glob(File.dirname(__FILE__) + '/config/*.rb') {|file| require file}
Dir.glob(File.dirname(__FILE__) + '/models/*') {|file| require file}
use Rack::MethodOverride

# *.html.erb
Tilt.register Tilt::ERBTemplate, 'html.erb'

# cookie
use Rack::Session::Cookie, :key => 'rack.session',
                            :path => '/',
                            :expire_after => 600, # In seconds
                            :secret => 'APP'
# flash
use Rack::Flash, :sweep => true

# warden
use Warden::Manager do |manager|
  manager.default_strategies :password
  manager.failure_app = App::Main
end

# run it
require './app.main'
require './app.failure'
map '/' do
  run App::Main
end