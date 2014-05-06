# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
  count = (textarea) ->
    $('span#micropost_content_count').text $(textarea).val().length

  $('textarea#micropost_content')
    .change -> count(this)
    .keyup -> count(this)

  count $('textarea#micropost_content')
