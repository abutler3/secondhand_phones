# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
jQuery ->
  Stripe.setPublishableKey($('meta[name="stripe-key"]').attr('content'))
  listing.setupForm()

listing =
  setupForm: ->
    $('#new_listing').submit ->
      if $('input').length = 6
        $('input[type=submit]').attr('disabled', true)
        Stripe.bankAccount.createToken($('#new_listing'), listing.handleStripeResponse)
        false

  handleStripeResponse: (status, response) ->
    if status == 200
      #If Complete Order button, when pressed, the order reaches Stripe
      $('#new_listing').append($('<input type="hidden" name="stripeToken" />').val(response.id))
      # Valid card token add a hidden field so stripe can process card
      $('#new_listing')[0].submit()
      # Submit form
    else
      # Failure
      $('#stripe_error').text(response.error.message).show()
      # Show unhides the message in the _form in orders
      $('input[type=submit]').attr('disabled', false)
      # If page error, reenable Complete Order button
