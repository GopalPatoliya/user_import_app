class UsersController < ApplicationController
  before_action :set_user, only: %i[ show edit update destroy ]

  # GET /users or /users.json
  def index
    @users = User.search(params[:search], params[:gender]).paginate(page: params[:page], per_page: 10)
  end

  # GET /users/1 or /users/1.json
  def show
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users or /users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to user_url(@user), notice: "User was successfully created." }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1 or /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to user_url(@user), notice: "User was successfully updated." }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1 or /users/1.json
  def destroy
    @user.destroy!

    respond_to do |format|
      format.html { redirect_to users_url, notice: "User was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  # Import users from CSV
  def import
    if params[:file].present?
      file = params[:file]
  
      # Validate file type
      unless file.content_type == 'text/csv' || file.original_filename.end_with?('.csv')
        redirect_to users_path, alert: 'Please upload a valid CSV file.'
        return
      end
  
      # Proceed with import if valid
      User.import(file)
      redirect_to users_path, notice: 'Users imported successfully.'
    else
      redirect_to users_path, alert: 'Please upload a file.'
    end
  end
  
  private

  # Use a before_action to find the user by ID
  def set_user
    @user = User.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to users_url, alert: 'User not found.'
  end

  # Only allow a list of trusted parameters through.
  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :contact, :gender)
  end
end
