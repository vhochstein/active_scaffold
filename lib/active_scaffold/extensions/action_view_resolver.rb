module ActionView
  class ActiveScaffoldResolver < FileSystemResolver
    # standard resolvers have a base path to views and append a controller subdirectory
    # activescaffolds view path do not have a subdir, so just remove the prefix
    # > rails 3.2.22 uses an additional fifth parameter
    def find_templates(name, prefix, partial, details, outside_app_allowed = false)
      if ::Rails::VERSION::MAJOR >= 4 || (::Rails::VERSION::MAJOR == 3 && ::Rails::VERSION::MINOR == 2 && ::Rails::VERSION::TINY >= 22)
        super(name,'',partial, details, outside_app_allowed)
      else
        super(name,'',partial, details)
      end
    end
  end
end
