class InterviewsController < ApplicationController
  before_action :set_interview, only: [:show, :edit, :update, :destroy]

  def index
    @interviews = Interview.all
  end

  def show
  end

  def new
    @interview = Interview.new
  end

  def edit
  end

  def create
    @interview = Interview.new interview_params
    @interview.member = current_member
    @interview.braintree_subscription_id = current_member.subscriptions

    @interview.save
    redirect_to :action => :review
  end
  
  def review
    
  end

  def update
    respond_to do |format|
      if @interview.update interview_params
        format.html { redirect_to @interview, notice: 'Interview was successfully updated.' }
        format.json { render :show, status: :ok, location: @interview }
      else
        format.html { render :edit }
        format.json { render json: @interview.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @interview.destroy
    respond_to do |format|
      format.html { redirect_to interviews_url, notice: 'Interview was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def set_interview
      @interview = Interview.find params[:id]
    end

    def interview_params
      params.require(:interview).permit(:expected, :frequent, :useful, :thoughts, :member_id, :braintree_subscription_id)
    end
end
