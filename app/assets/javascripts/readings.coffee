$(document).on 'turbolinks:load', ->
  setInterval resizeReading, 50
  attachFlippers()
  
  $('#upgrade_button').on 'click', (event) ->
    $('#first_card_panel').toggleClass 'flip'
    scrollIntoViewSmoothly($('#first_card_panel'))
    event.preventDefault()

window.resizeReading = ->
  $('.panel').each (i, p) ->
    image_height = $(p).find('img.source_cards_card_design').height()
    title_line_height = $(p).find('.title_line').height()
    if $(p).hasClass('flip')
      $(p).height $(p).find('.pane.back').outerHeight() + 30 + image_height + title_line_height
    else if $(p).hasClass('skip')
      $(p).height $(p).find('.pane.fore').outerHeight() + 30
    else
      $(p).height $(p).find('.pane.front').outerHeight() + 30 + image_height

window.attachFlippers = ->
  $('.card_reading_pane, .delivery_zone').off('click').on 'click', '.flip_card', (event) ->
    $(this).closest('.panel').toggleClass 'flip'
    scrollIntoViewSmoothly($(this).closest('.panel'))
    event.preventDefault()
  
  $('.card_reading_pane, .delivery_zone').on 'click', '.skip_card', (event) ->
    $(this).closest('.panel').toggleClass 'skip'
    scrollIntoViewSmoothly($(this).closest('.panel'))
    event.preventDefault()

scrollIntoViewSmoothly = (element) ->
  element[0].scrollIntoView({ behavior: 'smooth' })


window.cinderellaFlip = ->
  $('.panel.birth').removeClass 'skip'
  $('.panel.birth').addClass 'flip'
