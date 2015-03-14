jQuery ->
  tooltips()

  $('.show_review_journal input').on 'change', ->
    $('#review_journal').show()

  $('.hide_review_journal input').on 'change', ->
    $('#review_journal select').val("");
    $('#review_journal').hide()

  $('.show_next_div').on 'click', ->
    $(this).fadeOut()
    if $(this).next('div').is(':hidden')
      $(this).next('div').slideDown()
    else
      $(this).next('div').animate {
        opacity: 1,
        height: '100%',
      }, { duration: 500, complete: -> $(this).removeClass("expand_on_click") }

  $('.expand_on_click').on 'click', ->
    if !$(this).hasClass("expand_on_click")

    else if $(this).is(':hidden')
      $(this).prev('.show_next_div').fadeOut('100')
      $(this).slideDown
    else
      $(this).prev('.show_next_div').fadeOut('100')
      $(this).animate {
        opacity: 1,
        height: '100%',
      } , { duration: 500, complete: -> $(this).removeClass("expand_on_click") }

  $('.hide_on_click').on 'click', ->
    $(this).parent().prev('.show_next_div').fadeIn('100')
    $(this).parent().animate {
      opacity: 0.4,
      height: '25px',
    }, { duration: 500, complete: -> $(this).addClass("expand_on_click") }
