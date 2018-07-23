// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require rails-ujs
//= require activestorage
//= require turbolinks
//= require jquery3
//= require popper
//= require bootstrap
//= require moment
//= require fullcalendar
//= require fullcalendar/lang/en-au.js
//= require_tree .

function eventCalendar() {
  return $('#event_calendar').fullCalendar({
    defaultView: 'agendaWeek',
    minTime: '09:00:00',
    maxTime: '17:00:00',
    hiddenDays: [0, 6, 2, 4],
    allDaySlot: false,
    height: 'auto',
    selectable: true,
    selectConstraint: 'businessHours',
    validRange: function(nowDate) {
      return {
        start: nowDate,
        end: nowDate.clone().add(3, 'months')
      };
    },
    eventSources: [
      {
        url: '/event/busy_events'
      },
      {
        url: '/event/temp_events',
        data: {
          client_name: function() {
            return $('#event_client_attributes_name').val()
          },
          client_email: function() {
            return $('#event_client_attributes_email').val()
          },
        },
        color: 'darkgreen',
        textColor: 'lightgray'
      }
    ],
    select: function (start, end){
      $('#event_start').val(start.format());
      $.post(`/event/create_temp_event?${$('#new_event').serialize()}`).done(
        function() {
          $('#event_calendar').fullCalendar('refetchEvents');
        }
      );
    },
    businessHours: [
    {
      dow: [ 1, 3, 5 ],
      start: '09:00',
      end: '12:00'
    },
    {
      dow: [ 1, 3, 5 ],
      start: '13:00',
      end: '17:00'
    }]
  });
};
function clearCalendar() {
  $('#event_calendar').fullCalendar('delete'); // In case delete doesn't work.
  $('#event_calendar').html('');
};
$(document).on('turbolinks:load', eventCalendar);
$(document).on('turbolinks:before-cache', clearCalendar)
