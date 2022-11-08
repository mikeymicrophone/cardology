# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

class CardologySeeder
  def suit_up!
    ['Hearts', 'Clubs', 'Diamonds', 'Spades', 'No Suit'].each do |suit|
      Suit.find_or_create_by :name => suit
    end
  end
  
  def face_off!
    ['Ace', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine', 'Ten', 'Jack', 'Queen', 'King', 'Joker', 'Card Back'].each do |face|
      Face.find_or_create_by :name => face
    end
  end
  
  def deal!
    ['Hearts', 'Clubs', 'Diamonds', 'Spades'].each do |suit_name|
      suit = Suit.find_by :name => suit_name
      ['Ace', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine', 'Ten', 'Jack', 'Queen', 'King'].each do |face_name|
        face = Face.find_by :name => face_name
        Card.find_or_create_by :suit => suit, :face => face
      end
    end
    Card.find_or_create_by :suit => Suit.find_by(:name => 'No Suit'), :face => Face.find_by(:name => 'Joker')
    Card.find_or_create_by :suit => Suit.find_by(:name => 'No Suit'), :face => Face.find_by(:name => 'Card Back')
    Card.find_or_create_by :suit => Suit.find_by(:name => 'No Suit'), :face => Face.find_or_create_by(:name => 'Personality Card Back')
    Card.find_or_create_by :suit => Suit.find_by(:name => 'No Suit'), :face => Face.find_or_create_by(:name => 'Yearly Card Back')
    Card.find_or_create_by :suit => Suit.find_by(:name => 'No Suit'), :face => Face.find_or_create_by(:name => 'Planetary Card Back')
  end
  
  def spread_out!
    (0..89).each do |age|
      Spread.find_or_create_by :age => age
    end
  end
  
  def places_everyone!
    Spread.where(:age => (0..89).to_a).each do |spread|
      spread.quadrated_deck.each_with_index do |card, index|
        Place.find_or_create_by :spread => spread, :card => card, :position => index
      end
    end
  end
  
  def populate!
    suit_up!
    face_off!
    deal!
    spread_out!
    places_everyone!
  end
end

seeder = CardologySeeder.new
seeder.populate!

suits =  Suit.all
suits.each do |suit|
  cards = Card.where(suit_id: suit.id)
  if cards.present?
    cards.order(:face_id).each do |card|
      if suit.id == 5
        if card.face_id == 14
          card.update(image: "Joker_Red.jpg")
        elsif card.face_id == 15
          card.update(image: "blueorangeround-lowrez.jpg")
        else
          card.update(image: "blueround-lowrez.jpg")
        end
      else
        if card.face_id <= 10
          card.update(image: "#{suit.name.singularize}_#{card.face_id}.jpg")
        elsif card.face_id == 11
          card.update(image: "#{suit.name.singularize}_Jack.jpg")
        elsif card.face_id == 12
          card.update(image: "#{suit.name.singularize}_Queen.jpg")
        elsif card.face_id == 13
          card.update(image: "#{suit.name.singularize}_King.jpg")
        end
      end
    end
  end
end

