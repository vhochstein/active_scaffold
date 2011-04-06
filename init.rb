require 'active_scaffold'

begin
  ActiveScaffoldAssets.copy_to_public(ActiveScaffold.root, {:clean_up_destination => true})
rescue Exception => e
  # Heroku: Read only file system
  logger.info e.message
end
