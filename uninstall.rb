##
## Delete public asset files and configuration initializer
##

require 'fileutils'

directory = File.dirname(__FILE__)

[ :stylesheets, :javascripts, :images].each do |asset_type|
  path = File.join(directory, "../../../public/#{asset_type}/active_scaffold")
  FileUtils.rm_r(path)
end

# Remove initializer
FileUtils.rm(File.join(directory, "../../../config/initializers/active_scaffold.rb"))

FileUtils.rm(File.join(directory, "../../../public/blank.html"))
