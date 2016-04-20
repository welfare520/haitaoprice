# encoding: UTF-8
class ApplicationController < Sinatra::Base
  register Sinatra::Namespace

  set :root, File.join(File.dirname(__FILE__), '..')
  set :public_folder, File.dirname(__FILE__) + '/../public' 
  set :views, File.expand_path('../../views', __FILE__)
  set :auth_config, AuthConfig.new
  set :environment, :production
  enable :static
  enable :sessions
  set :sessions, :expire_after => 2592000

  configure do
    Dir.mkdir('logs') unless File.exist?('logs')
    file = File.new("logs/common.log", 'a+')
    file.sync = true
    use Rack::CommonLogger, file

    options = { :address              => "smtp.gmail.com",
                :port                 => 587,
                :domain               => 'localhost',
                :user_name            => 'hellofresh.BI',
                :password             => 'password-has-been-changed',
                :authentication       => 'plain',
                :enable_starttls_auto => true  }
            
    Mail.defaults do
      delivery_method :smtp, options
    end
  end  

  helpers ApplicationHelpers
  helpers AuthHelpers 

  helpers do
    def auth_config
      settings.auth_config
    end
  end

  # use Rack::Auth::Basic, "Provide HelloFresh user and pass" do |username, password|
  #   username == auth_config.user and password == auth_config.pass
  # end

  namespace '/' do

    error Sinatra::NotFound do
      content_type 'text/plain'
      [404, 'Page Not Found']
    end

    get do 
      redirect '/index'
    end

    get 'index' do      
      erb :main, :layout => :index
    end

    get 'products' do
      erb :products, :layout => :index 
    end
    
    namespace 'admin' do
      get do
        run_with_error_handling(["Admin", "Everyone"]) { |user|
          erb :"admin/admin", :locals => {
            :firstname => user.firstname, 
            :lastname => user.lastname
          }
        }  
      end

      get '/user/list' do
        run_with_error_handling(["Admin", "Everyone"]) { |user|
          erb :"admin/userlist", :layout => :"admin/admin", :locals => {
            :firstname => user.firstname, 
            :lastname => user.lastname,
            :users => Users.load_users.users
          }
        }
      end

      post '/user/:group/:username/:flag' do
        run_with_error_handling(["Admin", "Everyone"]) { |user|
          user = User.new(username: params[:username])
          user.fetch_user_details 
          user.update_group(params[:group], params[:flag])
          halt 201, {"status" => params[:flag]}.to_json 
        }
      end
    end


    get 'update' do
      erb :update 
    end

    get 'guide' do
      erb :guide
    end

    get 'header' do
      erb :header
    end

    get 'sidebar' do
      erb :sidebar
    end 

    get 'footer' do
      erb :footer
    end

  end
end

