require "rexml/xpath"
require "rexml/document"

module YouTrackEntities

  class User

    attr_reader :login, :password
    attr_accessor :fullName, :email, :jabber

    def initialize(connection, login)
      @login = login
      @conn = connection
    end

    def put
      [self.email, self.fullName].each{|var| raise ArgumentError if var.to_s.empty?}
      @conn.request(:put, self.path, self.user_properties).value
    end

    def post
      @conn.request(:post, self.path, self.user_properties).value
    end

    def get
      user_element = REXML::XPath.first(REXML::Document.new(@conn.request(:get, path).body), "//user")
      [:email, :fullName, :jabber].each{|elem| self.instance_variable_set("@#{elem}", user_element.attributes[elem.to_s])}
      self
    end

    private

    def path
      "#{@conn.rest_path}/admin/user/#{self.login}"
    end

    def user_properties
      props = {}
      [:fullName, :email, :jabber].each{|var|
        value = self.instance_variable_get("@#{var}")
        props[var] = value if !value.nil?
      }
    end

  end

  class Issue

    attr_reader :project_id, :issue_id
    attr_reader :comments, :attachments, :voters, :links

    def initialize(conn, project_id, issue_id)
      @project_id = project_id
      @issue_id = issue_id
      @conn = conn
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
  
end