module Exceptions 
  class DividedByZeroError < StandardError; end 
  class DataFormatError < StandardError; end 
  class SessionNotExist < StandardError; end 
  class AuthorizationFailure < StandardError; end
end