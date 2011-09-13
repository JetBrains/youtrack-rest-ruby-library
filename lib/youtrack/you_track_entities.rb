require "rexml/xpath"
require "rexml/document"

module YouTrackEntities

  class Issue

    attr_reader :project_id, :issue_id
    attr_reader :comments, :attachments, :voters, :links

    def initialize(conn, issue_id, project_id = nil)
      @conn = conn
      if project_id.nil?
        @issue_id = issue_id[/(\w+)-(\d+)/, 2]
        @id = issue_id[/(\w+)-(\d+)/, 1]
      else
        @issue_id = issue_id
        @id = project_id
      end
      @issue_params = {}
      @comments = {}
      @attachments = {}
      @links = {}
    end

    def get_param_names
      @issue_params.keys
    end

    def get_param(param_name)
      @issue_params[param_name]
    end

    def set_param(param_name, param_value)
      @issue_params[param_name] = param_value
    end

    def full_id
      "#{self.project_id}-#{self.issue_id}"
    end

    def apply_command(command, comment = nil, group = nil, disable_notifications = nil, run_as = nil)
      params = {:command => command,
                :comment => comment,
                :group => group,
                :disableNotifications => disable_notifications,
                :runAs => run_as}
      @conn.request(:post, "#{path}/execute", params)
    end

    def get
      body = REXML::Document.new(@conn.request(:get, path).body)
      REXML::XPath.each(body, "//issue/field"){ |field|
        values = []
        REXML::XPath.each(body, field.xpath + "/value") { |value|
          values << value.text
        }
        create_getter_and_setter_and_set_value(field.attributes["name"], values)
      }
      self
    end

#    def method_missing(m, *args)
#      if (m[-1, 1] == "=") and (args.length > 0)
#        self.create_getter_and_setter_and_set_value(m[0..-1], args)
#      end
#      raise NotImplementedError
#    end

    private

    def metaclass
      class << self;
        self
      end
    end

    def create_getter_and_setter_and_set_value(param_name, params = {})
      param_name = param_name.downcase
      metaclass.send(:define_method, param_name) do
        self.get_param(param_name)
      end
      metaclass.send(:define_method, param_name + "=") do |values|
        self.set_param(param_name, values)
      end
      self.set_param(param_name, params)
    end

    def path
      "#{@conn.rest_path}/issue/#{self.full_id}"
    end

  end

  class Project

    attr_accessor :lead, :name, :id

    def initialize(connection, project_name, project_id = nil, owner = nil)                                           2
      @conn = connection
      @id = project_id
      @name = project_name
      @lead = owner
    end

    def get
      project = REXML::XPath.first(REXML::Document.new(@conn.request(:get, self.path).body), "//project")
      [:name, :id, :lead].each{|elem| instance_variable_set("@#{elem}", project.attributes[elem.to_s])}
    end

    def put

    end

    def post

    end

    private

    def path
      "#{@conn.rest_path}/admin/project/#{id}"
    end

  end
  
end