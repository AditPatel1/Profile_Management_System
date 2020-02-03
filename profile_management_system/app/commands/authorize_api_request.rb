class AuthorizeApiRequest
  prepend SimpleCommand

  #def initialize(headers = {})
    #@headers = headers
  #end

  def initialize(user_auth_token)
    @user_auth_token = user_auth_token
  end

  def call
    #@token = auth_token
    user
  end

  private

  #attr_reader :cookies
  attr_reader :user_auth_token

  def user
    @user ||= User.find(decoded_auth_token[:user_id]) if decoded_auth_token
    @user || errors.add(:token, 'Invalid token') && nil
  end

  def decoded_auth_token
    #@decoded_auth_token ||= JsonWebToken.decode(http_auth_header)
    @decoded_auth_token ||= JsonWebToken.decode(user_auth_token)
  end

  #def http_auth_header()
    #if headers['Authorization'].present?
    #  return headers['Authorization'].split(' ').last
    #else
    #  errors.add(:token, 'Missing token')
    #end
    #nil
    #if headers['Cookie'].present?
      #byebug
      #return headers['Cookie']
    #else
      #errors.add(:token, 'Missing token')
    #end
  #end
end