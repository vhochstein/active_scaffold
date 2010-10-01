# Creates an initializer if it doesn't already exist
initializer = File.join(Rails.root, 'config', 'initializers', 'active_scaffold.rb')

unless File.exist? initializer
  File.open(initializer, 'w') do |f|
    f.puts "# Available options are :prototype and :jquery"
    f.puts "ActiveScaffold.js_framework = :prototype"
  end
end