# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
jQuery ->
  Stripe.setPublishableKey($('meta[name="stripe-key"]').attr('content'))
  payment.setupForm()

payment =
  setupForm: ->
    $('#new_order').submit ->
      $('input[type=submit]').attr('disabled', true)
      #Once you submit an order, disable complete order button
      Stripe.card.createToken($('#new_order'), payment.handleStripeResponse)
      false

  handleStripeResponse: (status, response) ->
    if status == 200
      #If Complete Order button, when pressed, the order reaches Stripe
      $('#new_order').append($('<input type="hidden" name="stripeToken" />').val(response.id))
      # Valid card token add a hidden field so stripe can process card
      $('#new_order')[0].submit()
      # Submit form
    else
      # Failure
      $('#stripe_error').text(response.error.message).show()
      # Show unhides the message in the _form in orders
      $('input[type=submit]').attr('disabled', false)
      # If page error, reenable Complete Order button
