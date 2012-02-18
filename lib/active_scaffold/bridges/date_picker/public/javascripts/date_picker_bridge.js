$(document).ready(function() {
  $('form.as_form, form.inplace_form').live('as:form_loaded', function(event) {
    var as_form = $(this).closest("form");
    as_form.find('input.datetime_picker').each(function(index) {
      var date_picker = $(this);
      if (typeof(date_picker.datetimepicker) == 'function') {
        date_picker.datetimepicker();
      }
    });

    as_form.find('input.date_picker').each(function(index) {
      var date_picker = $(this);
      if (typeof(date_picker.datepicker) == 'function') {
        date_picker.datepicker();
      }
    });
    return true;
  });
  $('form.as_form, form.inplace_form').live('as:form_unloaded', function(event) {
    var as_form = $(this).closest("form");
    as_form.find('input.datetime_picker').each(function(index) {
      var date_picker = $(this);
      if (typeof(date_picker.datetimepicker) == 'function') {
        date_picker.datetimepicker('destroy');
      }
    });

    as_form.find('input.date_picker').each(function(index) {
      var date_picker = $(this);
      if (typeof(date_picker.datepicker) == 'function') {
        date_picker.datepicker('destroy');
      }
    });
    return true;
  });
});