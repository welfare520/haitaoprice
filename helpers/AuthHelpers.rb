module AuthHelpers

  def authenticate! 
    session_id = env["rack.session"]["session_id"]    
    unless Sessions.new.session_valid?(session_id)  
      redirect '/users/login'
    end   
  end

  def authorized?(user, role)
    (role - user.group).empty? 
  end

  def run_with_error_handling(role=["Everyone"])
    begin
      unless env['rack.session.authentication'] 
        raise Exceptions::SessionNotExist, "session not found"
      end
      user = User.new(:username => env['rack.session.username'])
      user.fetch_user_details 
      unless authorized?(user, role)
        raise Exceptions::AuthorizationFailure, "unauthorized"
      end
      yield(user) if block_given?
    rescue Exceptions::SessionNotExist => e    
      redirect '/login.html'
    rescue Exceptions::AuthorizationFailure => e 
      redirect '/unauthorized.html'
    rescue Exceptions => e
      halt 400, {"status" => e.message}.to_json 
    end    
  end

end
