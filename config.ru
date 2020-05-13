require 'httpclient'
require 'pp'
require 'json'

require './engine/FakeResponse.rb'

require './controller.rb'
require './validate.rb'

use Rack::Reloader, 0
use Rack::Static, :urls => ['/public']

class Application
  def call env
    controller = Controller.new(env)

    return controller.index  if env['REQUEST_PATH'].match %r{^/$}
    return controller.sleepy if env['REQUEST_PATH'].match %r{^/sleepy$}
    return controller.nopage 

  end
end

run Application.new()