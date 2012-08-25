document.on('as:form_loaded', 'form.as_form', function(event) {
    var as_form = event.findElement('form');
    as_form.select('textarea.mceEditor').each(function(elem) {
      tinyMCE.execCommand('mceAddControl', false, elem.id);
    });
    return true;
  });
document.on('as:form_submit', 'form.as_form', function(event) {
    var as_form = event.findElement('form');
    if (as_form.select('textarea.mceEditor').length > 0) {
      tinyMCE.triggerSave();
    }
    return true;
  });
document.on('as:form_unloaded', 'form.as_form', function(event) {
    var as_form = event.findElement('form');
    as_form.select('textarea.mceEditor').each(function(elem) {
      tinyMCE.execCommand('mceRemoveControl', false, elem.id);
    });
    return true;
  });
