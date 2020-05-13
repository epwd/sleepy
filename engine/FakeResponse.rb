# encoding: UTF-8

class FakeResponse
  def initialize
    @count_responded = 0
    @count_urls = 0
    @th = []
  end
  def start urls, params
    # Debug
    console = params[:console]
    # max_time_request - In sec.
    max_time_request = params[:max_time_request]

    # Waiting all requests by their end
    @waiting_th = Thread.new { Thread.stop } 

    semaphore = Mutex.new

    @count_urls = urls.count
    @count_urls.times do
      @th << Thread.new do
        url = urls.pop
        timestamp = Time.now

        Thread.current[:data_request] = HTTPClient.get_content url
        Thread.current[:time_request] = (Time.now - timestamp) * 1000.0

        # Check finish all requests
        semaphore.synchronize { callback_terminate }
      end
    end

    # Waiting finished requests by (from front) max_time_request
    @waiting_th.join max_time_request

    puts "\nRequests terminated." if console

    responses = Hash.new
    @th.each_with_index do |thread,(i)|
      response = {}

      unless thread[:data_request].nil?
      begin
        response[:data_request] = JSON.parse thread[:data_request].gsub('=>', ':')
        response[:time_request] = thread[:time_request] # Time request in milisec.
      rescue Exception => e
        response = { :error => "#{e} -> #{data_request}" }
      end
      else
        response = { :error => "Request not completed or no response" }
      end

      responses[i] = response
    end

    if console
      puts "\nData prepared."
      pp responses
    end

    return processing(responses)
  end

private
  def callback_terminate
    @count_responded += 1
    if @count_responded >= @count_urls
      @th.each do |thread|
        thread.exit unless Thread.current==thread
      end
      @waiting_th.exit
    end
  end

  def processing responses
    sum = 0.0
    errors = []
    data = {}

    responses.each do |key,hash|
      begin
        slept = hash[:data_request]['slept']
        # If error this not do
        sum += slept
      rescue Exception => e
      end

      if hash.has_key?(:error)
        errors << {"\"Error request\"" => hash[:error]}
        responses.delete(key)
      end
    end

    data[:data] = responses
    data[:sum] = sum
    data[:errors] = errors if errors
    
    return data
  end
end