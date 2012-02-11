# TODO: clean up extensions. some could be organized for autoloading, and others could be removed entirely.
ActiveSupport.on_load(:action_controller) do
  ['array', 'localize', 'nil_id_in_url_params', 'paginator_extensions', 'routing_mapper'].each do |extension|
    require "#{File.dirname __FILE__}/active_scaffold/extensions/#{extension}.rb"
  end
  include ActiveScaffold
  include RespondsToParent
  include ActiveScaffold::Helpers::ControllerHelpers
  class_eval {include ActiveRecordPermissions::ModelUserAccess::Controller}
end

ActiveSupport.on_load(:action_view) do
  ['name_option_for_datetime', 'action_view_rendering', 'action_view_resolver', 'usa_state'].each do |extension|
    require "#{File.dirname __FILE__}/active_scaffold/extensions/#{extension}.rb"
  end
  include ActiveScaffold::Helpers::ViewHelpers
end

ActiveSupport.on_load(:active_record) do
  ['active_association_reflection', 'reverse_associations', 'to_label', 'unsaved_record'].each do |extension|
    require "#{File.dirname __FILE__}/active_scaffold/extensions/#{extension}.rb"
  end
  class_eval {include ActiveRecordPermissions::ModelUserAccess::Model}
  class_eval {include ActiveRecordPermissions::Permissions}
end

I18n.load_path += Dir[File.join(File.dirname(__FILE__), 'active_scaffold', 'locale', '*.{rb,yml}')]
#ActiveScaffold.js_framework = :prototype
