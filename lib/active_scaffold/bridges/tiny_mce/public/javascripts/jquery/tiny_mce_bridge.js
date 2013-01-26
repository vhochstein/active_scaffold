$(document).on('as:form_loaded', 'form.as_form, form.inplace_form', function(event) {
    var as_form = $(this).closest("form");
    as_form.find('textarea.as_mceEditor').each(function(index, elem) {
      tinyMCE.execCommand('mceAddControl', false, $(elem).attr('id'));
    });
    return true;
  });
$(document).on('as:form_submit', 'form.as_form, form.inplace_form', function(event) {
    var as_form = $(this).closest("form");
    if (as_form.has('textarea.as_mceEditor').length > 0) {
      tinyMCE.triggerSave();
    }
    return true;
  });
$(document).on('as:form_unloaded', 'form.as_form, form.inplace_form', function(event) {
    var as_form = $(this).closest("form");
    as_form.find('textarea.as_mceEditor').each(function(index, elem) {
      tinyMCE.execCommand('mceRemoveControl', false, $(elem).attr('id'));
    });
    return true;
  });
