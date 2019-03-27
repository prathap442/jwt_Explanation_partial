class UsersController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :set_user, only: [:show, :destroy]
  # GET /users
  # GET /users.json
  def index
    @users = User.all
  end

  # GET /users/1
  # GET /users/1.json
  def show
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
    response = check_for_headers_having_valid_data(request)
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)
    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    response = check_for_headers_having_valid_data(request)
    respond_to do |format|
      format.json { render json: {data: @user.token,jwt_verification_info: @jwt_verification_info}.to_json }
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def check_for_headers_having_valid_data(req)
    binding.pry
    request = req
    @jwt_verification_info = {found: false,user_id: nil,expiry_info: nil}
    if(request.env["HTTP_X_AUTH"])
      @jwt_token = request.env["HTTP_X_AUTH"]
      if(@jwt_token)
        @pay_load = (JWT.decode @jwt_token,"UNIQUE", true, { algorithm: 'HS256' })[0] 
        current_time = Time.now
        if(@pay_load["user_id"] != nil)
          @user = User.find(@pay_load["user_id"].to_i)
          if(@user)
            if(@user.token == @jwt_token)
              @jwt_verification_info[:found] = true
              @jwt_verification_info[:user_id] = @user.id
              @jwt_verification_info[:expiry_info] = current_time - (@user.token_expiry.to_time)
              if(@user.token_expiry.to_time < current_time)
                @jwt_verification_info[:found] = true
                @jwt_verification_info[:user_id] = @user.id
                @jwt_verification_info[:expiry_info] = (current_time) - (@user.token_expiry.to_time) 
                puts "<!----------->"
                puts "we are updating the token for the current user"
                puts "<!----------->"
                timing = current_time + 2.minutes
                @user.token_expiry = timing
                exp_payload = {expiry_timing: timing,user_id: @user.id}
                @user.token = JWT.encode exp_payload, 'UNIQUE', 'HS256' 
                @user.save
                return @jwt_verification_info.to_json
              elsif(@user.token_expiry >= current_time)
                puts "the token is valid"
                puts "the expiration has not yet happended"
                puts "the time left for expiration is CurrentTime:#{current_time} + TokenExpiry:#{@user.token_expiry} +Timeleft: #{current_time.to_time-@user.token_expiry.to_time}"
                @jwt_verification_info[:expiry_info] = "#{current_time.to_time-@user.token_expiry.to_time}"
                return @jwt_verification_info.to_json
              else
                puts "a case of unexpection"
                return @jwt_verification_info
              end
            else
              puts "false token being given"
              @jwt_verification_info[:user_id] = @user.id
              @jwt_verification_info[:expiry_info] = (@user.token_expiry.to_time) - current_time 
            end
          else
            @jwt_verification_info = {found: false,user_id: nil,expiry_info: "you are not authorizaed or you're record is not found"}
          end  
        end     
      else
        return @jwt_verification_info
      end
    else
      @jwt_verification_info[:expiry_info] = "no jwt exists unauthorized access"
    end  
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:firstname, :lastname, :token, :token_expiry)
    end
end
