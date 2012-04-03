module Rails
  module Generators
    class ActiveScaffoldSetupGenerator < Rails::Generators::Base #metagenerator
      argument :js_lib, :type => :string, :default => 'jquery', :desc => 'js_lib for activescaffold (prototype|jquery)'
      
      def self.source_root
         @source_root ||= File.join(File.dirname(__FILE__), 'templates')
      end

      def install_plugins
      end
      
      def configure_active_scaffold
        unless defined?(ACTIVE_SCAFFOLD_GEM)
          if js_lib == 'jquery'
            gsub_file 'vendor/plugins/active_scaffold/lib/active_scaffold_env.rb', /#ActiveScaffold.js_framework = :jquery/, 'ActiveScaffold.js_framework = :jquery'
          end
        else
          if js_lib == 'jquery'
            create_file "config/initializers/active_scaffold.rb", "ActiveScaffold.js_framework = :jquery"
          end
        end
      end
      
      def configure_application_layout
        if js_lib == 'prototype'
        elsif js_lib == 'jquery'
          inject_into_file "app/assets/javascripts/application.js",
"//= require jquery
//= require jquery-ui
//= require jquery_ujs
//= require active_scaffold\n",
                   :before => "//= require_tree"
          inject_into_file "app/assets/stylesheets/application.js",
" *= require active_scaffold\n",
                   :before => " *= require_self"
           
          inject_into_file "config/locales/en.yml",
"  time:
    formats:
      default: \"%a, %d %b %Y %H:%M:%S\"",                  
                   :after => "hello: \"Hello world\"\n"
        end
      end     
    end
  end
end