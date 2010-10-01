module Rails
  module Generators
    class ActiveScaffoldSetupGenerator < Rails::Generators::Base
      argument :js_lib, :type => :string, :default => 'prototype', :desc => 'JavaScript framework used by ActiveScaffold (prototype|jquery)'
      
      def self.source_root
         @source_root ||= File.join(File.dirname(__FILE__), 'templates')
      end

      def install_plugins
        plugin 'verification', :git => 'git://github.com/rails/verification.git'
        plugin 'render_component', :git => 'git://github.com/vhochstein/render_component.git'

        if js_lib == 'prototype'
          get "http://github.com/vhochstein/prototype-ujs/raw/master/src/rails.js", "public/javascripts/rails.js" 
        elsif js_lib == 'jquery'
          get "http://github.com/vhochstein/jquery-ujs/raw/master/src/rails.js", "public/javascripts/rails_jquery.js"
          get "http://github.com/vhochstein/jQuery-Timepicker-Addon/raw/master/jquery-ui-timepicker-addon.js", "public/javascripts/jquery-ui-timepicker-addon.js"
        end
      end

      # TODO : Make active_scaffold_includes pull the right includes depending on the
      # configured js framework instead of hardcode it in app/views/layout/application.html.erb
      def configure_application_layout
        if js_lib == 'prototype'
          inject_into_file "app/views/layouts/application.html.erb", 
                    "  <%= active_scaffold_includes %>\n",
                    :after => "<%= javascript_include_tag :defaults %>\n"
        elsif js_lib == 'jquery'
          inject_into_file "app/views/layouts/application.html.erb", 
"  <%= stylesheet_link_tag 'http://ajax.googleapis.com/ajax/libs/jqueryui/1.8.4/themes/ui-lightness/jquery-ui.css' %>
  <%= javascript_include_tag 'http://ajax.googleapis.com/ajax/libs/jquery/1.4.1/jquery.js' %>
  <%= javascript_include_tag 'rails_jquery.js' %>
  <%= javascript_include_tag 'http://ajax.googleapis.com/ajax/libs/jqueryui/1.8.4/jquery-ui.js' %>
  <%= javascript_include_tag 'jquery-ui-timepicker-addon.js' %>
  <%= javascript_include_tag 'application.js' %>
  <%= active_scaffold_includes %>\n",
                   :after => "<%= javascript_include_tag :defaults %>\n"
           
          inject_into_file "config/locales/en.yml",
"  time:
    formats:
      default: \"%a, %d %b %Y %H:%M:%S\"",                  
                   :after => "hello: \"Hello world\"\n"
          gsub_file 'app/views/layouts/application.html.erb', /<%= javascript_include_tag :defaults/, '<%# javascript_include_tag :defaults'
        end
      end


      # Just in case someone installs AS, starts the application and realizes that
      # the setup hasn't been made properly
      def tweak_initializer_if_present
        initializer = File.join(Rails.root, 'config', 'initializers', 'active_scaffold.rb')

        if File.exist?(initializer)
          if js_lib == 'prototype'
            gsub_file initializer, /=\s?\:jquery/, '= :prototype'
          elsif js_lib == 'jquery'
            gsub_file initializer, /=\s?\:prototype/, '= :jquery'
          end
        end
      end
    end
  end
end