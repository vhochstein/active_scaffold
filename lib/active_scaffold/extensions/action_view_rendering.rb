module ActionView
  class LookupContext
    module ViewPaths

      def find_all_templates(name, partial = false, locals = {})
        prefixes.collect do |prefix|
          @view_paths.collect do |resolver|
            if Rails::VERSION::MINOR == 1
              temp_args = *args_for_lookup(name, [prefix], partial, locals)
            else
              temp_args = *args_for_lookup(name, [prefix], partial, locals, {})
            end
            temp_args[1] = temp_args[1][0]
            resolver.find_all(*temp_args)
          end
        end.flatten!
      end
    end
  end
end

# wrap the action rendering for ActiveScaffold views
module ActionView #:nodoc:
  class Renderer
  #
  # Adds two rendering options.
  #
  # ==render :super
  # ==render :partial => :super, :locals =>{:headline => 'formheadline'}
  #
  # This syntax skips all template overrides and goes directly to the provided ActiveScaffold templates.
  # Useful if you want to wrap an existing template. Just call super!
  #
  # ==render :active_scaffold => #{controller.to_s}, options = {}+
  #
  # Lets you embed an ActiveScaffold by referencing the controller where it's configured.
  #
  # You may specify options[:constraints] for the embedded scaffold. These constraints have three effects:
  #   * the scaffold's only displays records matching the constraint
  #   * all new records created will be assigned the constrained values
  #   * constrained columns will be hidden (they're pretty boring at this point)
  #
  # You may also specify options[:conditions] for the embedded scaffold. These only do 1/3 of what
  # constraints do (they only limit search results). Any format accepted by ActiveRecord::Base.find is valid.
  #
  # Defining options[:label] lets you completely customize the list title for the embedded scaffold.
  #
    def render_with_active_scaffold(context, options, &block)
      if options && options[:partial] == :super
        render_as_super_view(context, options, &block)
      elsif options[:active_scaffold]
        render_as_embedded_view(context, options, &block)
      else
        render_as_view(context, options, &block)
      end
    end
    alias_method_chain :render, :active_scaffold

    def render_partial_with_active_scaffold(context, options, &block) #:nodoc:
      if block_given?
        render(context, options, block)
      else
        render(context, options)
      end
    end
    alias_method_chain :render_partial, :active_scaffold

    def render_template_with_active_scaffold(context, options) #:nodoc:
      render(context, options)
    end
    alias_method_chain :render_template, :active_scaffold


    def render_as_super_view(context, options, &block)
      last_view = @view_stack.last
      options[:locals] ||= {}
      options[:locals].reverse_merge!(last_view[:locals] || {})
      if last_view[:templates].nil?
        last_view[:templates] = lookup_context.find_all_templates(last_view[:view], !last_view[:is_template], options[:locals].keys)
        last_view[:templates].shift
      end
      options[:template] = last_view[:templates].shift
      @view_stack << last_view
      options.delete(:partial) if options[:partial] == :super
      result = if options.key?(:partial)
        render_partial_without_active_scaffold(last_view[:context], options)
      else
        render_template_without_active_scaffold(last_view[:context], options)
      end
      @view_stack.pop
      result
    end

    def render_as_embedded_view(context, options, &block)
      require 'digest/md5'
      remote_controller = options[:active_scaffold]
      constraints = options[:constraints]
      conditions = options[:conditions]
      eid = Digest::MD5.hexdigest(context.controller.controller_name + remote_controller.to_s + constraints.to_s + conditions.to_s)
      options[:params] ||= {}
      options[:params].merge! :eid => eid, :embedded => true
      url_options = {:controller => remote_controller.to_s, :action => 'index'}.merge(options[:params])

      label = options[:label] || context.controller.class.active_scaffold_controller_by_controller_name(remote_controller.to_s).active_scaffold_config.list.label
      context.controller.session["as:#{eid}"] = {:constraints => constraints, :conditions => conditions, :list => {:label => options[:label]}}
      
      id = "as_#{eid}-content"
     
      if context.controller.respond_to?(:render_component_into_view, true)
        context.controller.send(:render_component_into_view, url_options)
      else
        if !context.controller.respond_to?(:uses_active_scaffold?) || context.controller.send(:uses_active_scaffold?) == false
          # have to add activescaffold view path cause parentcontroller is not activescaffold enabled
          ActiveScaffold.default_view_paths.each do |path|
            context.controller.append_view_path(ActionView::ActiveScaffoldResolver.new(path))
          end
        end
        url_options.delete(:embedded)
        options[:locals] ||= {}
        options[:locals].merge!({:url_options => url_options, :id=> id, :remote_controller => remote_controller})
        options[:partial] = 'embedded_controller'
        options.delete(:active_scaffold)
        options.delete(:params)
        render(context, options)
      end
    end

    def render_as_view(context, options, &block)
       if options.is_a?(Hash)
          current_view = {:view => options[:partial], :is_template => false} if options[:partial]
          current_view = {:view => options[:template], :is_template => !!options[:template]} if current_view.nil? && options[:template]
          if current_view.present?
            current_view[:locals] = options[:locals] if options[:locals]
            current_view[:context] = context
            @view_stack ||= []
            @view_stack << current_view
          end
        end
        result = if options.key?(:partial)
          render_partial_without_active_scaffold(context, options, &block)
        else
          render_template_without_active_scaffold(context, options, &block)
        end
        result
    end
  end

  
end
