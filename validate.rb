class Validate
  def initialize rack_input
    @rack_input = rack_input
  end

  def sleepy
    max_time_request = @rack_input['max_time_request'].to_i
    
    @rack_input['urls'].each do |url|
      return false unless 0 == (url =~ /#{URI::regexp(['http', 'https'])}/)
    end if max_time_request >= 1 and max_time_request <= 10 if max_time_request.is_a? Integer

    return true
  end 
end