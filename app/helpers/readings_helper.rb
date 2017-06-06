module ReadingsHelper
  def card_reading_pane card, reading, title, subtitle, side = 'front', &block
    div_for @birthday, "#{reading}_card_for", :class => "card_reading_pane pane #{side}" do
      content_tag(:header, title) +
      content_tag(:header, subtitle, :class => 'subtitle') +
      if card
        div_for(card, :identification_of) do
          div_for(card, :name_of) do
            card.name
          end +
          image_tag(card.image, :class => 'card_face_image')
        end +
        div_for(card, :explication_of) do
          mark_up interpretation_of(card, reading)
        end
      end +
      if block_given?
        capture(&block)
      end
    end
  end
  
  def zodiac_picker_for member, birthday
    if birthday == member.birthday
      link_to(birthday.zodiac_for_birthday.leader.capitalize, member_assign_zodiac_path(:id => member.id, :member => {:zodiac_sign => birthday.zodiac_for_birthday.leader}), :method => :put, :remote => true, :class => 'zodiac_selection flip_card') +
      link_to(birthday.zodiac_for_birthday.follower.capitalize, member_assign_zodiac_path(:id => member.id, :member => {:zodiac_sign => birthday.zodiac_for_birthday.follower}), :method => :put, :remote => true, :class => 'zodiac_selection flip_card')
    else
      link_to(birthday.zodiac_for_birthday.leader.capitalize, personality_for_zodiac_birthday_path(birthday, :zodiac_sign => birthday.zodiac_for_birthday.leader), :remote => true, :class => 'zodiac_selection flip_card') +
      link_to(birthday.zodiac_for_birthday.follower.capitalize, personality_for_zodiac_birthday_path(birthday, :zodiac_sign => birthday.zodiac_for_birthday.follower), :remote => true, :class => 'zodiac_selection flip_card')
    end
  end
end