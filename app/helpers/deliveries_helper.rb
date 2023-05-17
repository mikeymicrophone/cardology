module DeliveriesHelper
  def source_card_url card
    'https://www.thesourcecards.com/' + card.name.gsub(' ', '-') if card
  end
  
  def birthday_card_url birthday, card
    'https://www.thesourcecards.com/' + Date::MONTHNAMES[birthday.month] + '-' + birthday.day.ordinalize + '-birthday-' + card.numeric_name.gsub(' ', '-')
  end
  
  def personality_card_reading_link card
    link_to(source_card_url(card), :class => 'nodeco', :target => :blank) do
      image_tag(card.image.url) +
      content_tag(:div, :id => 'personality_card_title_line', :class => 'title_line') do
        content_tag(:div, source_cards_marketing_text('card_reading', 'personality_card', 'identification')) +
        card.name + '.' +
        content_tag(:div, source_cards_marketing_text('card_reading', 'personality_card', 'symbolizing')) +
        content_tag(:div, source_cards_marketing_text('card_reading', 'personality_card', 'instructions'))
      end
    end
  end
end
