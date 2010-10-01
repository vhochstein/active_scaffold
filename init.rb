##
## Initialize the environment
##
unless Rails::VERSION::MAJOR == 3 && Rails::VERSION::MINOR >= 0
  raise "This version of ActiveScaffold requires Rails 3.0 or higher.  Please use an earlier version."
end

require File.dirname(__FILE__) + '/environment'

##
## Run the install assets script, too, just to make sure
## But at least rescue the action in production
##
begin
  %w{assets initializer}.each do |installer|
    require File.join(File.dirname(__FILE__), "install_#{installer}")
  end
rescue
  raise $! unless Rails.env == 'production'
end
