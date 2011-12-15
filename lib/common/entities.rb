require "rexml/xpath"
require "rexml/document"

module Entities

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


end