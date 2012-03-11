module ActiveScaffold
  #do not use module Rails... cause Rails.logger will fail
  # not sure if it is a must though...
  #module Rails
    class Engine < ::Rails::Engine
      initializer "initialize_active_scaffold" do
        # TODO: clean up extensions. some could be organized for autoloading, and others could be removed entirely.
        ActiveSupport.on_load(:action_controller) do
          ['array', 'localize', 'nil_id_in_url_params', 'paginator_extensions', 'routing_mapper'].each do |extension|
            require "#{File.dirname __FILE__}/extensions/#{extension}.rb"
          end
          include ActiveScaffold
          include RespondsToParent
          include ActiveScaffold::Helpers::ControllerHelpers
          class_eval {include ActiveRecordPermissions::ModelUserAccess::Controller}
        end

        ActiveSupport.on_load(:action_view) do
          ['name_option_for_datetime', 'action_view_rendering', 'action_view_resolver', 'usa_state'].each do |extension|
            require "#{File.dirname __FILE__}/extensions/#{extension}.rb"
          end
          include ActiveScaffold::Helpers::ViewHelpers
        end

        ActiveSupport.on_load(:active_record) do
          ['active_association_reflection', 'reverse_associations', 'to_label', 'unsaved_associated', 'unsaved_record'].each do |extension|
            require "#{File.dirname __FILE__}/extensions/#{extension}.rb"
          end
          class_eval {include ActiveRecordPermissions::ModelUserAccess::Model}
          class_eval {include ActiveRecordPermissions::Permissions}
        end
      end
    end
  #end
end
