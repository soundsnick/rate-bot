require 'socket'
require 'uri'
require 'telegram/bot'
require 'json'

require_relative './controllers/Controller'
require_relative './config/Settings'
require_relative './controllers/Notification'

@bot
@params = {}

# Bot listener on a new Thread
Thread::new do
  Telegram::Bot::Client.run(Settings.bot['token']) do |bot|
    @bot = bot
    bot.listen do |message|
      Controller.handle(@bot, message)
    end
  end
end

# Application Server
def make_params(route)
  get_params = route.split("?")
  if get_params.length > 0
    get_params = get_params[1].split("&")
    get_params.each do |param|
      get = param.split("=")
      @params[get[0]] = get[1]
    end
  end
end

server = TCPServer.new(Settings.api['ip'], Settings.api['port'])
loop do
  session = server.accept
  session.print "HTTP/1.1 200/OK\r\nContent-type:text/html\r\n\r\n"
  if request = session.gets
    route = request.gsub(/GET\ \//, '').gsub(/\ HTTP.*/, '').chomp
    @par_count = false
  end
  if route.index("?")
    make_params route
    @par_count = true
  end

  @params = {} if not @par_count and not route.index("favicon")

  if route.split("?")[0] == "notify"
    session.print JSON.pretty_generate Notification.add(@bot, @params['token'], @params['email'], @params['text'])
  else
    session.print "API"
  end
  session.close
end
