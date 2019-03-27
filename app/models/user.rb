class User < ApplicationRecord
  require 'jwt'  
  @@hmac_secret = "UNIQUE"  
  after_create :create_the_user_token,:change_the_token_expiry_time,on: :create
  def create_the_user_token
    exp_payload = {expiry_timing: (Time.now+2.minutes),user_id: self.id}
    self.token =  JWT.encode exp_payload, @@hmac_secret, 'HS256'
    self.save
  end

  def change_the_token_expiry_time
    if(self.token != nil)
      token_expiry = JWT.decode token, @@hmac_secret, true, { algorithm: 'HS256' }
      self.token_expiry = token_expiry[0]["expiry_timing"].to_time
      self.save
    end
  end
end
