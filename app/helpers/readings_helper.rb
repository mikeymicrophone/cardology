module ReadingsHelper
  def card_reading_pane card, reading, title, subtitle, side = 'front', &block
    if side != 'front' && !@member.subscribed?
      subscription_marketing_pane side
    else
      div_for @birthday, "#{reading}_card_for", :class => "card_reading_pane pane #{side}" do
        content_tag(:header, title) +
        content_tag(:header, subtitle, :class => 'subtitle') +
        if card
          div_for(card, :identification_of) do
            div_for(card, :name_of) do
              card.name
            end +
            image_tag(card.image.url, :class => 'card_face_image') +
            div_for(Card.last, :opportunities_on) do
              if [:yearly, :planetary].include? reading
                "#{marketing_text 'coaching', 'question'} #{link_to(marketing_text('coaching', 'answer'), ENV['COACHING_PURCHASE_LINK'], :target => '_blank')}".html_safe
              else
                "#{marketing_text 'book', 'question'} #{link_to(marketing_text('book', 'answer'), ENV['BOOK_PURCHASE_LINK'], :target => '_blank')}".html_safe
              end
            end
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
  end
  
  def subscription_marketing_pane side = 'fore'
    card = @birthday.birth_card
    div_for @birthday, 'subscription_marketing_for', :class => "card_reading_pane pane #{side}" do
      content_tag(:header, marketing_text('subscription', 'teaser', 'header')) +
      content_tag(:header, marketing_text('subscription', 'teaser', 'subheader'), :class => 'subtitle') +
      div_for(card, :identification_of) do
        div_for(card, :name_of) do
          card.name
        end +
        image_tag(card.image.url, :class => 'card_face_image') +
        div_for(Card.last, :opportunities_on) do
          "#{marketing_text 'book', 'question'} #{link_to(marketing_text('book', 'answer'), ENV['BOOK_PURCHASE_LINK'], :target => '_blank')}".html_safe
        end
      end +
      div_for(card, :explication_of) do
        mark_up marketing_text 'subscription', 'teaser', 'offer'
      end +
      checkout_form +
      link_to(marketing_text('subscription', 'teaser', 'accept'), 'javascript: null', :class => 'subscribe call_to_action trailing lunar_navigation') +
      link_to(marketing_text('subscription', 'teaser', 'defer'), 'javascript: null', :class => "#{side == 'fore' ? 'skip_card' : 'flip_card'} call_to_action trailing lunar_navigation")
    end
  end
  
  def zodiac_picker_for member, birthday
    if member.nil?
      link_to(image_tag(asset_path("zodiac/#{birthday.zodiac_for_birthday.leader}.png"), :class => 'sign_icon') + birthday.zodiac_for_birthday.leader.capitalize.to_s, personality_for_zodiac_birthday_path(birthday, :zodiac_sign => birthday.zodiac_for_birthday.leader, :source_cards => true), :remote => true, :class => 'zodiac_selection') +
      link_to(image_tag(asset_path("zodiac/#{birthday.zodiac_for_birthday.follower}.png"), :class => 'sign_icon') + birthday.zodiac_for_birthday.follower.capitalize, personality_for_zodiac_birthday_path(birthday, :zodiac_sign => birthday.zodiac_for_birthday.follower, :source_cards => true), :remote => true, :class => 'zodiac_selection')
    elsif birthday == member&.birthday
      link_to(birthday.zodiac_for_birthday.leader.capitalize, member_assign_zodiac_path(:id => member.id, :member => {:zodiac_sign => birthday.zodiac_for_birthday.leader}), :method => :put, :remote => true, :class => 'zodiac_selection flip_card') +
      link_to(birthday.zodiac_for_birthday.follower.capitalize, member_assign_zodiac_path(:id => member.id, :member => {:zodiac_sign => birthday.zodiac_for_birthday.follower}), :method => :put, :remote => true, :class => 'zodiac_selection flip_card')
    else
      link_to(birthday.zodiac_for_birthday.leader.capitalize, personality_for_zodiac_birthday_path(birthday, :zodiac_sign => birthday.zodiac_for_birthday.leader), :remote => true, :class => 'zodiac_selection flip_card') +
      link_to(birthday.zodiac_for_birthday.follower.capitalize, personality_for_zodiac_birthday_path(birthday, :zodiac_sign => birthday.zodiac_for_birthday.follower), :remote => true, :class => 'zodiac_selection flip_card')
    end
  end
  
  def quick_zodiac_picker birthday
    
  end
  def card_reading_pane_gui card, reading, title, subtitle
    
    div_for @birthday, "#{reading}_card_for", :class => "card_reading_pane_gui pane", style: "width: 235px;" do
      content_tag(:header, title) +
      content_tag(:header, subtitle, :class => 'subtitle') +
      if card
        div_for(card, :identification_of) do
          div_for(card, :name_of) do
            card.name
          end +
          image_tag(card.image.url, :class => 'card_face_image_gui', style:"width:85px") +
          div_for(Card.last, :opportunities_on) do
           
          end
        end +
        div_for(card, :explication_of) do
          mark_up interpretation_of(card, reading)
        end
      end 
      
    end
  
end
end
