require "rexml/xpath"
require "rexml/document"

module EAEntities

  class Exception
    attr_reader :project, :id, :params
    attr_accessor :trace

    def initialize(conn, exception_id, lang, project_id = nil, trace = "", additional_params = {})
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
    end

    def get
      exception = REXML::XPath.first(REXML::Document.new(@conn.request(:get, self.path).body), "//exception")
      exception.attributes.each { |name, value| self.instance_variable_set(name, value) }
      self.trace = REXML::XPath.first(exception, "//trace/text()")
      REXML::XPath.each(exception, "//params/param") { |param|
        self.param[param.attributes[:name]] = REXML::XPath.first(param, "/text()")
      }
    end

    def put


    end

    private

    def path
      "#{@conn.rest_path}/exception/#{self.project}-#{self.id}"
    end

  end

  class ExceptionProject

  end

end