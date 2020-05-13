class Controller

  def initialize env
    @env = env

    begin
      @rack_input = JSON.parse(env['rack.input'].read)
    rescue Exception => e
      return render 'dynamic', 'error validate'
    end

    @validate = Validate.new(@rack_input)
    # engine code
    @fake_response = FakeResponse.new
    #...
  end

  def index
    render 'static', IO.read("./views/index.htm", :encoding => 'UTF-8')
  end

  def sleepy
    return render 'dynamic', 'error validate' unless @validate.sleepy

    params = {
      :console => false,
      :max_time_request => @rack_input['max_time_request'].to_i
    }

    urls = @rack_input['urls']

    render 'dynamic', @fake_response.start(urls, params)
  end

  def nopage
    render 'dynamic', 'nopage'
  end

private
  def render type, content=''
    case type
    when 'static'
      [200, {'Content-Type' => 'text/html', 'charset' => 'utf-8'}, [content]]
    when 'dynamic'
      [200, { 'Content-Type' => 'text/plain', 'charset' => 'utf-8' }, [content.to_json]]
    end
  end
end
