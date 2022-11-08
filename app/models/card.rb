class Card < ApplicationRecord
  belongs_to :suit
  belongs_to :face
  has_many :interpretations
  # mount_uploader :image, CardUploader
  
  def self.ordered_deck
    deck = []
    ['Hearts', 'Clubs', 'Diamonds', 'Spades'].each do |suit_name|
      suit = Suit.find_by :name => suit_name
      ['Ace', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine', 'Ten', 'Jack', 'Queen', 'King'].each do |face_name|
        face = Face.find_by :name => face_name
        card = Card.find_by :suit => suit, :face => face
        deck << card
      end
    end
    return deck.reverse
  end
  
  def self.joker
    find_by(:face => Face.find_by(:name => 'Joker'))
  end
  
  def inspect
    if face.name == 'Joker'
      'Joker'
    else
      "#{face.name} of #{suit.name}"
    end
  end
  
  def name
    inspect
  end
  
  def numeric_name
    if face.name == 'Joker'
      'Joker'
    elsif [1, 11, 12, 13].include? face.number
      "#{face.name} of #{suit.name}"
    else
      "#{face.number} of #{suit.name}"
    end
  end
  
  def self.card_back_image
    find_by(:face => Face.find_by(:name => 'Card Back'))&.image
  end
  
  def self.personality_card_back_image
    find_by(:face => Face.find_by(:name => 'Personality Card Back'))&.image
  end
  
  def self.yearly_card_back_image
    find_by(:face => Face.find_by(:name => 'Yearly Card Back'))&.image
  end
  
  def self.planetary_card_back_image
    find_by(:face => Face.find_by(:name => 'Planetary Card Back'))&.image
  end
end
