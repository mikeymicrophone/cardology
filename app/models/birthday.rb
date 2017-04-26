Cusp = Struct.new(:leader, :follower, :is_cusp?)
class Birthday < ApplicationRecord
  attr_accessor :date, :zodiac_sign
  
  def name
    birthdate.strftime("%B %-d, %Y")
  end
  
  def birthdate_string
    birthdate.strftime("%Y-%m-%d")
  end
  
  def birth_card
    deck = Card.ordered_deck.unshift(Card.find_by(:face => Face.find_by(:name => 'Joker')))
    position = month * 2 + day
    deck.reverse[54 - position]
  end

  def birthdate
    Date.new year, month, day
  end
  
  def age
    ((Date.today - birthdate) / (1.year / 1.day)).floor
  end
  
  def age_on_date date
    ((date - birthdate) / (1.year / 1.day)).floor
  end
  
  def days_since_birthday #including the birthday
    days_since_birthday_on_date Date.today
  end
  
  def days_since_birthday_on_date date
    today = Date.today
    if date.month > month
      last_birthday = Date.new date.year, month, day
    elsif date.month < month || date.day < day
      last_birthday = Date.new(date.year - 1, month, day)
    else
      last_birthday = Date.new date.year, month, day
    end
    day_before_birthday = last_birthday - 1
    (date - day_before_birthday).floor
  end
  
  def card_for_this_year
    card_for_the_year_on_date Date.today
  end
  
  def card_for_last_year
    card_for_the_year_on_date(Date.today - 1.year)
  end
  
  def card_for_the_year_on_date date
    long_range_spread_index = age_on_date(date) / 7
    planetary_position = (age_on_date(date) % 7) + 1
    spread = Spread.find_by(:age => long_range_spread_index)
    position_of_birth_card = spread.position_of birth_card
    position = position_of_birth_card.position - planetary_position
    position = 52 + position if position < 0
    place = Place.find_by :spread_id => spread.id, :position => position
    place.card
  end
  
  def card_for_this_planet
    card_for_the_planetary_period_on_date Date.today
  end
  
  def card_for_last_planet
    card_for_the_planetary_period_on_date(Date.today - 52.days)
  end
  
  def card_for_the_planetary_period_on_date date
    spread = Spread.find_by(:age => age_on_date(date))
    planetary_position = (days_since_birthday_on_date(date) / 52) + 1
    return Card.joker if planetary_position > 7
    position_of_birth_card = spread.position_of birth_card
    position = position_of_birth_card.position - planetary_position
    position = 52 + position if position < 0
    place = Place.find_by :spread_id => spread.id, :position => position
    place.card
  end
  
  def personality_card
    # self.zodiac_sign = :cancer
    spread = Spread.find_by(:age => 0)
    position_of_birth_card = spread.position_of birth_card
    planetary_ruling_position = position_of_birth_card.position - number_for_planet(planet_for_sign(astrological_sign))
    place = Place.find_by :spread_id => spread.id, :position => planetary_ruling_position
    place.card
  end
  
  def astrological_sign
    zodiac_sign || case birthdate.month
    when 1
      case birthdate.day
      when 1..19
        :capricorn
      when 20..21
        cusp(:capricorn, :aquarius)
      when 22..31
        :aquarius
      end
    when 2
      case birthdate.day
      when 1..18
        :aquarius
      when 19..20
        cusp(:aquarius, :pisces)
      when 21..29
        :pisces
      end
    when 3
      case birthdate.day
      when 1..19
        :pisces
      when 20..21
        cusp(:pisces, :aries)
      when 22..31
        :aries
      end
    when 4
      case birthdate.day
      when 1..19
        :aries
      when 20..21
        cusp(:aries, :taurus)
      when 22..30
        :taurus
      end
    when 5
      case birthdate.day
      when 1..19
        :taurus
      when 20..21
        cusp(:taurus, :gemini)
      when 22..31
        :gemini
      end
    when 6
      case birthdate.day
      when 1..20
        :gemini
      when 21..22
        cusp(:gemini, :cancer)
      when 23..30
        :cancer
      end
    when 7
      case birthdate.day
      when 1..21
        :cancer
      when 22..23
        cusp(:cancer, :leo)
      when 24..31
        :leo
      end
    when 8
      case birthdate.day
      when 1..21
        :leo
      when 22..23
        cusp(:leo, :virgo)
      when 24..31
        :virgo
      end
    when 9
      case birthdate.day
      when 1..21
        :virgo
      when 22..23
        cusp(:virgo, :libra)
      when 24..30
        :libra
      end
    when 10
      case birthdate.day
      when 1..22
        :libra
      when 23..24
        cusp(:libra, :scorpio)
      when 23..31
        :scorpio
      end
    when 11
      case birthdate.day
      when 1..20
        :scorpio
      when 21..22
        cusp(:scorpio, :sagittarius)
      when 23..30
        :sagittarius
      end
    when 12
      case birthdate.day
      when 1..20
        :sagittarius
      when 21..22
        cusp(:sagittarius, :capricorn)
      when 23..31
        :capricorn
      end
    end
  end
  
  def cusp leader, follower
    Cusp.new(leader, follower, true)
  end
  
  def planet_for_sign sign
    case sign
    when :aries
      :mars
    when :taurus
      :venus
    when :gemini
      :mercury
    when :cancer
      :moon
    when :leo
      :sun
    when :virgo
      :mercury
    when :libra
      :venus
    when :scorpio
      :mars
    when :sagittarius
      :jupiter
    when :capricorn
      :saturn
    when :aquarius
      :saturn
    when :pisces
      :jupiter
    end
  end
  
  def number_for_planet planet
    case planet
    when :mercury
      1
    when :venus
      2
    when :mars
      3
    when :jupiter
      4
    when :saturn
      5
    when :neptune
      6
    when :uranus
      7
    when :pluto
      8
    when :sun
      0
    when :moon
      -1
    end
  end
  
  def reading
    "Birth Card: #{birth_card.inspect}<br>This Year: #{card_for_this_year.inspect}<br>52-day Card: #{card_for_this_planet.inspect}"
  end
end

class Symbol
  def is_cusp?
    false
  end
end
