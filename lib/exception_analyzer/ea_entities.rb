require "rexml/xpath"
require "rexml/document"

module EAEntities

  class Exception
    attr_reader :project, :id, :params
    attr_accessor :trace, :lang

    def initialize(conn, exception_id, lang = nil, project_id = nil, trace = "", additional_params = {})
      @conn = conn
      if project_id.nil?
        @id = issue_id[/(\w+)-(\d+)/, 2]
        @project = issue_id[/(\w+)-(\d+)/, 1]
      else
        @project = project_id
        @id = exception_id
      end
      @trace = trace
      @params = additional_params
      @lang = lang
    end

    def get
      exception = REXML::XPath.first(REXML::Document.new(@conn.request(:get, self.my_path).body), "//exception")
      exception.attributes.each { |name, value| self.instance_variable_set(name, value) }
      self.trace = REXML::XPath.first(exception, "//trace/text()")
      REXML::XPath.each(exception, "//params/param") { |param|
        self.param[param.attributes[:name]] = REXML::XPath.first(param, "/text()")
      }
    end

    def put
      content = REXML::Document.new
      exception = content.root_node.add_element("exception")
      [:project, :lang].each { |field|
        value = self.instance_variable_get(field)
        unless value.nil?
          exception.add_attribute(field, value)
        end
      }
      unless self.trace.nil?
        exception.add_element(:trace).text = self.trace
      end
      additional_params = exception.add_element("additional_params")
      self.params.each { |key, value|
        additional_params.add_element("param", {"name" => key}).text = value
      }
      @conn.request(:put, self.path, body = content)
    end

    private

    def my_path
      "#{self.path}#{self.project}-#{self.id}"
    end

    def path
      "#{@conn.rest_path}/exception/"
    end

  end

  class ExceptionProject

    attr_reader :shortName, :name

    def initialize(conn, short_name, name = nil)
      @conn = conn
      @shortName = short_name
      @name = name
    end

    def get
      project = REXML::XPath.first(REXML::Document.new(@conn.request(:get, self.my_path).body), "//project")
      project.attributes.each { |name, value| self.instance_variable_set(name, value) }
    end

    def put
      content = REXML::Document.new
      project = content.root_node.add_element("project")
      [:shortName, :name].each { |field| project.add_attribute(field, self.instance_variable_get(field)) }
      @conn.request(:put, self.path, body = content)
    end

    private

    def my_path
      self.path + self.shortName
    end

    def path
      "#{@conn.rest_path}/exceptionProject/"
    end

  end

end