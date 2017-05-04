# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on 'turbolinks:load', ->
  $('#getresponse_delivery').validate()
  $('.reading_display_container').on 'submit', '#getresponse_delivery', (event) ->
    $.ajax
      url: '/member_save'
      method: 'POST'
      data:
        member:
          birthday_id: $('div.birthday').data('birthday_id')
          name: $('#member_first_name').val()
          email: $('#member_email').val()
          lookup_id: $('div.birthday').data('lookup_id')
    
    $.ajax
      url: 'https://app.getresponse.com/add_subscriber.html'
      method: 'POST'
      data:
        $(this).serialize()
    
    event.preventDefault()

  $('.identification_of_card').on 'click', '.flip_over', ->
    $('#member_first_name').focus()
