class Calendar
  attr_accessor :birthdate
  
  PLANETS = ['Mercury', 'Venus', 'Mars', 'Jupiter', 'Saturn', 'Uranus', 'Neptune']
  
  def transition_dates
    birthdate.dates_of_planetary_shifts
  end
  
  def triples_for_year
    transition_dates.each_with_index do |date, index|
      [date, PLANETS[index], birthdate.card_for_the_planetary_period_on_date(date)]
    end
  end
  
  def calendar_string
    triples_for_year.map do |date, planet, card|
      "Move to #{card.name} in #{planet} on #{date}"
    end.join
  end
end
