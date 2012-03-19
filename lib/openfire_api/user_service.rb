require "awesome_print"

class OpenfireApi::UserService

  @@api_path = "plugins/userService/userservice"
  @@api_exceptions = %w(UserServiceDisabled RequestNotAuthorised IllegalArgumentException UserNotFoundException UserAlreadyExistsException)

  class HTTPException < StandardError; end
  class InvalidResponseException < StandardError; end
  class UserServiceDisabledException < StandardError; end
  class RequestNotAuthorisedException < StandardError; end
  class IllegalArgumentException < StandardError; end
  class UserNotFoundException < StandardError; end
  class UserAlreadyExistsException < StandardError; end

  def initialize(options=Hash.new)
    @options = { :path => @@api_path }.merge(options)
  end

  def add_user!(opts)
    submit_request(opts.merge(:type => :add))
  end

  def delete_user!(opts)
    submit_request(opts.merge(:type => :delete))
  end

  def update_user!(opts)
    submit_request(opts.merge(:type => :update))
  end

  def lock_user!(opts)
    submit_request(opts.merge(:type => :disable))
  end

  def unlock_user!(opts)
    submit_request(opts.merge(:type => :enable))
  end

private

  def build_query(params)
    "#{build_query_uri.to_s}?#{build_query_params(params)}"
  end

  def build_query_uri
    uri = URI.parse(@options[:url])
    uri.path = File.join(uri.path, @@api_path)
    uri
  end

  def build_query_params(params)
    params.merge!(:secret => @options[:secret])
    params.to_a.map{ |p| "#{p[0]}=#{p[1]}" }.join('&')
  end

  def submit_request(params)
    puts "Submit Request with [params]:"
    ap params
    data = submit_http_request(build_query_uri, build_query_params(params))
    parse_response(data)
  end

  def submit_http_request(uri, params)
    puts "Here we submit the http request [uri]: #{uri}:"
    ap params
    http = Net::HTTP.new(uri.host, uri.port)
    resp = http.get("#{uri.path}?#{params}")
    puts "Testing the resp and data:"
    ap resp.body
    return resp.body
  rescue Exception => e
    raise HTTPException, e.to_s
  end

  def parse_response(data)
    puts "Testing"
    ap data
    error = data.match(/<error>(.*)<\/error>/)
    if error && @@api_exceptions.include?(error[1])
      raise eval("#{error[1].gsub('Exception', '')}Exception")
    end
    raise InvalidResponseException unless data.match(/<result>ok<\/result>/)
    return true
  end

end
