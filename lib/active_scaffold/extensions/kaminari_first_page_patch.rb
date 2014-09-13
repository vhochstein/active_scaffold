module Kaminari
  module Helpers
    class Tag
      #kaminary sets page 1 to nil.. that conflicts withc activescaffold, cause in case of nil we try to use page stored in session
      def page_url_for(page)
        @template.url_for @params.merge(@param_name => (page <= 1 ? 1 : page), :only_path => true)
      end
    end
  end
end