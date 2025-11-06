//= require actioncable
//= require_self

window.GOVUK = window.GOVUK || {}
const protocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:';
if (window.location.host == 'govuk-chat.dev.gov.uk') {
  window.GOVUK.consumer = ActionCable.createConsumer(`ws://localhost:3000/cable`);
} else {
  window.GOVUK.consumer = ActionCable.createConsumer(`${protocol}//${window.location.host}/cable`);
}
