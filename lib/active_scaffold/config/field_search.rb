module ActiveScaffold::Config
  class FieldSearch < Base
    self.crud_type = :read

    def initialize(core_config)
      super

      @text_search = self.class.text_search
      @or_delimiter = self.class.or_delimiter
    end


    # global level configuration
    # --------------------------
    # the ActionLink for this action
    cattr_reader :link
    @@link = ActiveScaffold::DataStructures::ActionLink.new('show_search', :label => :search, :type => :collection, :security_method => :search_authorized?, :ignore_method => :search_ignore?)

    # A flag for how the search should do full-text searching in the database:
    # * :full: LIKE %?%
    # * :start: LIKE ?%
    # * :end: LIKE %?
    # * false: LIKE ?
    # Default is :full
    cattr_accessor :text_search
    @@text_search = :full

    # delimiter to seperate or search string such us: name = Paul,Bernd,Klaus
    # will search for Paul Or Bernd Or Klaus
    cattr_accessor :or_delimiter
    @@or_delimiter = ','

    # instance-level configuration
    # ----------------------------

    # provides access to the list of columns specifically meant for the Search to use
    def columns
      # we want to delay initializing to the @core.columns set for as long as possible. Too soon and .search_sql will not be available to .searchable?
      unless @columns
        self.columns = @core.columns._inheritable
        self.columns.exclude @core.columns.active_record_class.locking_column.to_sym
      end
      @columns
    end

    public :columns=

    # A flag for how the search should do full-text searching in the database:
    # * :full: LIKE %?%
    # * :start: LIKE ?%
    # * :end: LIKE %?
    # * false: LIKE ?
    # Default is :full
    attr_accessor :text_search

    attr_accessor :or_delimiter
    
    # the ActionLink for this action
    attr_accessor :link
    
    # rarely searched columns may be placed in a hidden subgroup
     def optional_columns=(optionals)
      @optional_columns= Array(optionals)
    end
    
    def optional_columns
      @optional_columns ||= []
    end

    # columns which should support or searches
    # eg like 'x' or ... like 'y'
    def or_columns=(or_columns)
      @or_columns = Array(or_columns)
    end

    def or_columns
      unless @or_columns
        self.or_columns = @core.columns.collect{|c| c.name if @core.columns._inheritable.include?(c.name) and c.searchable? and c.column and c.column.text?}.compact
      end
      @or_columns
    end
    
    # default search params
    # default_params = {:title => {"from"=>"test", "to"=>"", "opt"=>"%?%"}} 
    attr_accessor :default_params
    
    # human conditions
    # instead of just filtered you may show the user a humanized search condition statment
    attr_accessor :human_conditions
    
  end
end
