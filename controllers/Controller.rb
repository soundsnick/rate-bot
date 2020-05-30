require 'pry'

require_relative './Commands'
require_relative '../config/Settings'
require_relative '../models/Context'

class Controller
  # description: Entrypoint for bot service.
  # Gets income message object, and triggers appropriate method from the routes

  @routes = {
    '/start' => 'Commands#start',
    '/error' => 'Commands#error',
    '/login' => 'Commands#login',
    '/gethistory' => 'Commands#get_history'
  }

  # Parses message body for command
  def self.make_route(message)
    route = '/error'
    tmp_route = message.match(/^\/[\w\-]+/)
    route = tmp_route[0] if tmp_route
    @routes[route] || @routes['/error']
  end

  # Entrypoint method that handles user input
  def self.handle(bot, message)
    if message.text == '/cancel'
      Commands.cancel(bot, message)
    else
      route_tmp = "/error"
      if @context = Context.get_state(message.chat.id) and @context.length > 0
        route_tmp = @context
      else
        route_tmp = message.text
      end
      route = make_route(route_tmp).split('#')
      route_controller = Module.const_get(route[0])
      route_controller.send(route[1], bot, message)
    end
  end

  # User authentication check
  def self.is_authenticated(access_token)
    access_token == Settings.api['token']
  end
  
end
