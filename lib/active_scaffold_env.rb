# TODO: clean up extensions. some could be organized for autoloading, and others could be removed entirely.
Dir["#{File.dirname __FILE__}/active_scaffold/extensions/*.rb"].each { |file| require file }
ActiveSupport.on_load(:action_controller) do
  include ActiveScaffold
  include RespondsToParent
  include ActiveScaffold::Helpers::ControllerHelpers
  class_eval {include ActiveRecordPermissions::ModelUserAccess::Controller}
end

ActiveSupport.on_load(:action_view) do
  include ActiveScaffold::Helpers::ViewHelpers
end

ActiveSupport.on_load(:active_record) do
  class_eval {include ActiveRecordPermissions::ModelUserAccess::Model}
  class_eval {include ActiveRecordPermissions::Permissions}
end

I18n.load_path += Dir[File.join(File.dirname(__FILE__), 'active_scaffold', 'locale', '*.{rb,yml}')]
#ActiveScaffold.js_framework = :jquery
