module Secured
  def auth_user!
    token_regex = /Bearer (\w+)/
    headers = request.headers
    if headers['Authorization'].present? && headers['Authorization'].match(token_regex)
      token = headers['Authorization'].match(token_regex)[1]
      user = User.find_by_auth_token(token)
      if(Current.user = User.find_by_auth_token(token))
        return
      end
    end
    render json: {error: 'Unauthorized'}, status: :unauthorized
  end
  
end