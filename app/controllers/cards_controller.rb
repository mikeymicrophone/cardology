class CardsController < ApplicationController
  before_action :set_card, only: [:edit, :update]
  load_and_authorize_resource
  
  def index
    @cards = Card.all
  end
  
  def edit
    debugger
  end
  
  def update
    if @card.update(card_params)
      redirect_to cards_path, notice: "Card successfully updated."
    else
      render :edit
    end
  end
  
  protected
  
  def set_card
    @card = Card.find(params[:id])
  end
  
  def card_params
    params.require(:card).permit(:image)
  end
end
