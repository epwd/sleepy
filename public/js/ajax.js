
function func(action) {
  var response = new Object();
  var ajaxTime = new Date().getTime();

  var params = new Object();
  params.max_time_request = $('#max-time-request').val();
  params.urls = $('#urls').val().split('\n');

  $.ajax({
    type: 'POST',
    url: '/' + action,
    async: true,
    contentType: 'application/json; charset=UTF-8',
    data: JSON.stringify(params),
    success: function(s) {
      processing(s);
    },
    beforeSend: function() {
      document.getElementById("sleepy").disabled = true;
      $('#json-renderer').empty().append('Please Wait...');
      return console.log('AJAX sended');
    }
  });

  function processing(s){
    // Time request - First!
    response.total = new Date().getTime()-ajaxTime;

    json = JSON.parse(s);

    if (json=="error validate") {
      response.data = [];
      response.sum = 0.0;
      response.errors = ["error validate"];
    } else {
      response.data = json['data'];
      response.sum = json['sum'];
      response.errors = json['errors'];
    }

    $('#json-renderer').empty().jsonViewer(response);
    document.getElementById("sleepy").disabled = false; 
  }
}