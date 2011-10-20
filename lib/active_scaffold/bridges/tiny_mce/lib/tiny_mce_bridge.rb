module ActiveScaffold
  module TinyMceBridge
    module ViewHelpers
    end

    module FormColumnHelpers
      def active_scaffold_input_text_editor(column, options)
        options[:class] = "#{options[:class]} as_mceEditor #{column.options[:class]}".strip
        html = []
        html << send(override_input(:textarea), column, options)
        html.join "\n"
      end
    end

    module SearchColumnHelpers
      def self.included(base)
        base.class_eval { alias_method :active_scaffold_search_text_editor, :active_scaffold_search_text }
      end
    end
  end
end

ActionView::Base.class_eval do
  include ActiveScaffold::TinyMceBridge::FormColumnHelpers
  include ActiveScaffold::TinyMceBridge::SearchColumnHelpers
  include ActiveScaffold::TinyMceBridge::ViewHelpers
end
