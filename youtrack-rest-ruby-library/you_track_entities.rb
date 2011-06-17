module YouTrackEntities

  def find_user(search_params)

  end

  class User

    attr_accessor :login, :email, :full_name, :additional_params

    def initialize(login)
      @login = login
    end

    def put
      [@login, @email, @full_name].each{|var| raise ArgumentError if var.to_s.empty?}
    end

    def post

    end

    def get

    end

  end
  
end