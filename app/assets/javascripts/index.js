$(function() {
	var $header = $('#header')
	if($header.length > 0) {
		// scrolling fx for the sticky header / menu
		$(window).scroll(function (e) {
			if($header.length > 0 && $header.offset().top > 20 ) {
				if(!$header.hasClass('compact')){
					$header.addClass('compact')
				}
			} else {
				$header.removeClass('compact')
			}
		})
	}

	// search box
	var $search = $('[data-bind-searchAction]')
	var $searchform = $('#searchform')
	var searchAction = function (event) {
		// prevent
		event.preventDefault()
		$(this).toggleClass('iconOff')
		$searchform.toggleClass('show')
	}

	if($search.length > 0) {
		$search.on('click', searchAction)
	}

	var $calendar = $('#calendar')
	if($calendar.length > 0) {
		$calendar.fullCalendar(fullCalendarCFG)
	}
});
function businessHours(){
  var openTime  = new Date();
  openTime.setUTCHours('1');
  openTime.setUTCMinutes('0');
  openTime.setUTCSeconds('0');
  var closeTime = new Date();
  closeTime.setUTCHours('9');
  closeTime.setUTCMinutes('0');
  closeTime.setUTCSeconds('0');

  businessHours = { minTime: openTime.toLocaleTimeString(), maxTime: closeTime.toLocaleTimeString() };
};
function loadTimetable(){
  var agentId = $("input[name='event[agent_id]']:checked").val();
  var eventTypeId = $("#event_event_type_id").val();
  var email = $('#event_client_attributes_email').val();
  $.get("/event/timetable", {agent_id: agentId, event_type_id: eventTypeId, client_email: email })
   .done(function(response){
     console.log(response);
     timetable = response;
     clearCalendar();
     eventCalendar();
   });
};
function loadClientByEmail(email) {
  $.get("/client_by_email", {email: email}).done(function(data) {
    if (data.client) {
      $("#event_client_attributes_name").val(data.client.name);
      $("#event_client_attributes_premium").val(data.client.premium);
      $("#event_client_attributes_phone").val(data.client.phone);
      $("#event_client_attributes_location").val(data.client.location);
      $("#subsequent_event").val(data.subsequent_event);
      if (data.event_type_id) {
        $("[name='event[event_type_id]']").val(data.event_type_id);
      }
      if (data.appointment_id) {
        $("[name='event[appointment_id]']").val(data.appointment_id);
        $("[name='event[appointment_id]']").trigger('change');
      }
      if (data.agent_id) {
        $(`#event_agent_id_${data.agent_id}`).prop('checked', true);
        $(`#event_agent_id_${data.agent_id}`).trigger('change');
      }
    }
  });
};
function setProperModal() {
  var modalId = 'onshoreModal';
  if ($('#subsequent_event').val() === 'true' ) {
    modalId = 'returnCustomerModal';
  } else {
    if ($("[name='event[appointment_id]']").val() == 1) {
      modalId = 'offshoreModal';
    } else {
      modalId = 'onshoreModal';
    }
  }
  $('#bookNowBtn').attr('data-target', `#${modalId}`);
};
function filterEventTypes(appointment_id) {
  if (appointment_id == '1') {
    $("#event_event_type_id option:first").attr('disabled', true);
  } else {
    $("#event_event_type_id option:first").attr('disabled', false);
  }

  if ($("#event_event_type_id option:selected").val() == '1') {
    $("#event_event_type_id option:selected").removeAttr('selected');
    $("#event_event_type_id").val('2');
  }
}
function filterAppointmentType(location) {
  if (location == 'Perth') {
    $('#event_appointment_id').val('2');
  } else {
    $('#event_appointment_id').val('1');
  }
  $("#event_appointment_id").trigger('change');
};
