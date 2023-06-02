class CelestialsController < ApplicationController
  before_action :set_celestial, only: [:show, :edit, :update, :destroy]

  def index
    @celestials = Celestial.all
  end

  def show
  end

  def new
    @celestial = Celestial.new
  end

  def edit
  end

  def create
    @celestial = Celestial.new(celestial_params)
    @celestial.member = current_member

    if @celestial.save
      redirect_to @celestial.birthday, notice: 'Celestial was successfully created.'
    else
      render :new
    end
  end

  def update
    if @celestial.update(celestial_params)
      redirect_to @celestial.birthday, notice: 'Celestial was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @celestial.destroy
    redirect_to current_member.birthday, notice: 'Celestial was successfully destroyed.'
  end

  private

  def set_celestial
    @celestial = Celestial.find(params[:id])
  end

  def celestial_params
    params.require(:celestial).permit(:birthday_id, :name)
  end
end
