module ActiveScaffold::Actions
  module List
    def self.included(base)
      base.before_filter :list_authorized_filter, :only => [:index, :row]
      base.helper_method :list_columns
      base.helper_method :save_current_page_num
    end

    def index
      list
    end

    # get just a single row
    def row
      @record = find_if_allowed(params[:id], :read)
      respond_to_action(:row)
    end

    def list
      do_list
      do_new if active_scaffold_config.list.always_show_create
      @record ||= new_model if active_scaffold_config.list.always_show_search
      @nested_auto_open = active_scaffold_config.list.nested_auto_open
      respond_to_action(:list)
    end
    
    protected
    def list_respond_to_html
      if params.delete(:embedded)
        render :action => 'list', :layout => false
      else
        render :action => 'list'
      end
    end
    def list_respond_to_js
      if params.delete(:embedded)
        render(:partial => 'list_with_header')
      else
        render :action => 'list.js'
      end
    end
    def list_respond_to_xml
      column_names = successful? ? list_columns_names : error_object_attributes
      render :xml => response_object.to_xml(:only => column_names, :methods => virtual_columns(column_names)), :content_type => Mime::XML, :status => response_status
    end
    def list_respond_to_json
      column_names = successful? ? list_columns_names : error_object_attributes
      render :text => response_object.to_json(:only => column_names, :methods => virtual_columns(column_names)), :content_type => Mime::JSON, :status => response_status
    end
    def list_respond_to_yaml
      column_names = successful? ? list_columns_names : error_object_attributes
      render :text => Hash.from_xml(response_object.to_xml(:only => column_names, :methods => virtual_columns(column_names))).to_yaml, :content_type => Mime::YAML, :status => response_status
    end
    
    def row_respond_to_html
      render(:partial => 'row', :locals => {:record => @record})
    end

    def row_respond_to_js
      render(:partial => 'row', :locals => {:record => @record})
    end

    # The actual algorithm to prepare for the list view
    def do_list
      includes_for_list_columns = active_scaffold_config.list.columns.collect{ |c| c.includes }.flatten.uniq.compact
      self.active_scaffold_includes.concat includes_for_list_columns

      options = { :sorting => active_scaffold_config.list.user.sorting,
        :count_includes => active_scaffold_config.list.user.count_includes }
      paginate = (params[:format].nil?) ? (accepts? :html, :js) : ['html', 'js'].include?(params[:format].to_s)
      if paginate
        options.merge!({
            :per_page => active_scaffold_config.list.user.per_page,
            :page => active_scaffold_config.list.user.page,
            :pagination => active_scaffold_config.list.pagination
          })
      end

      if active_scaffold_config.model.respond_to?(:tableless?) && active_scaffold_config.model.tableless?
        @records = Kaminari.paginate_array(active_scaffold_config.model.all)
        @records = @records.page(options[:page]).per(options[:per_page]) if options[:pagination]
      else
        @records = find_page(options);
      end
      @records
    end

    def each_record_in_page
      _page = active_scaffold_config.list.user.page
      do_search if respond_to? :do_search
      active_scaffold_config.list.user.page = _page
      do_list
      @page.items.each {|record| yield record}
    end

    def each_record_in_scope
      do_search if respond_to? :do_search
      finder_options = { :order => "#{active_scaffold_config.model.connection.quote_table_name(active_scaffold_config.model.table_name)}.#{active_scaffold_config.model.primary_key} ASC",
        :conditions => all_conditions,
        :joins => joins_for_finder}
      finder_options.merge! custom_finder_options
      finder_options.merge! :include => (active_scaffold_includes.blank? ? nil : active_scaffold_includes)
      klass = beginning_of_chain
      klass.all(finder_options).each {|record| yield record}
    end

    # The default security delegates to ActiveRecordPermissions.
    # You may override the method to customize.
    def list_authorized?
      authorized_for?(:crud_type => :read)
    end

    # call this method in your action_link action to simplify processing of actions
    # eg for member action_link :fire
    # process_action_link_action do |record|
    #   record.update_attributes(:fired => true)
    #   self.successful = true
    #   flash[:info] = 'Player fired'
    # end
    def process_action_link_action(render_action = :action_update)
      if request.get?
        # someone has disabled javascript, we have to show confirmation form first
        @record = find_if_allowed(params[:id], :read) if params[:id] && params[:id] && params[:id].to_i > 0
        respond_to_action(:action_confirmation)
      else
        begin
          if params[:id] && params[:id] && params[:id].to_i > 0
            @record = find_if_allowed(params[:id], (request.post? || request.put?) ? :update : :delete)
            unless @record.nil?
              yield @record
            else
              self.successful = false
              flash[:error] = as_(:no_authorization_for_action, :action => action_name)
            end
          else
            yield
          end
        rescue ActiveRecord::RecordInvalid
        rescue ActiveRecord::StaleObjectError
          @record.errors.add(:base, as_(:version_inconsistency)) unless @record.nil?
          self.successful=false
        rescue ActiveRecord::RecordNotSaved
          @record.errors.add(:base, as_(:record_not_saved)) if !@record.nil? && @record.errors.empty?
          self.successful = false
        end
        respond_to_action(render_action)
      end
    end

    def action_confirmation_respond_to_html(confirm_action = action_name.to_sym)
      link = active_scaffold_config.action_links[confirm_action]
      render :action => 'action_confirmation', :locals => {:record => @record, :link => link}
    end

    def action_update_respond_to_html
      do_search if respond_to? :do_search
      do_list
      redirect_to :action => 'index'
    end

    def action_update_respond_to_js
      render(:action => 'on_action_update')
    end

    def action_update_respond_to_xml
      column_names = successful? ? list_columns_names : error_object_attributes
      render :xml => response_object.to_xml(:only => column_names, :methods => virtual_columns(column_names)), :content_type => Mime::XML, :status => response_status
    end

    def action_update_respond_to_json
      column_names = successful? ? list_columns_names : error_object_attributes
      render :text => response_object.to_json(:only => column_names, :methods => virtual_columns(column_names)), :content_type => Mime::JSON, :status => response_status
    end

    def action_update_respond_to_yaml
      column_names = successful? ? list_columns_names : error_object_attributes
      render :text => Hash.from_xml(response_object.to_xml(:only => column_names, :methods => virtual_columns(column_names))).to_yaml, :content_type => Mime::YAML, :status => response_status
    end

    def save_current_page_num
      active_scaffold_config.list.user.page = @records.current_page unless active_scaffold_config.list.pagination == false
    end
     
    private
    def list_authorized_filter
      raise ActiveScaffold::ActionNotAllowed unless list_authorized?
    end

    def list_formats
      (default_formats + active_scaffold_config.formats + active_scaffold_config.list.formats).uniq
    end
    alias_method :row_formats, :list_formats

    def action_update_formats
      (default_formats + active_scaffold_config.formats).uniq
    end

    def action_confirmation_formats
      (default_formats + active_scaffold_config.formats).uniq
    end

    def list_columns
      active_scaffold_config.list.columns.collect_visible
    end

    def list_columns_names
      list_columns.collect(&:name)
    end
  end
end
