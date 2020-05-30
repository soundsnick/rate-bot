require 'cgi'

require_relative '../db/ORM'
require_relative './Controller'
require_relative '../models/User'
require_relative '../models/History'

class Notification < Controller
  # description: HTTP service controller that handles XHR and sends notification to user

  def self.add(bot, token, email, text)
    if not is_authenticated(token)
      return {
        status: 204,
        message: "Unauthorized",
        body: {
          email: email,
          text: text
        }
      }
    end

    if User.is_authorized_email(email) and History.add(email, text)
      bot.api.send_message(chat_id: User.get_chat_id(email), text: "Новое уведомление: " + CGI.unescape(text))
      return {
        status: 200,
        message: "Sent",
        body: {
          chat_id: User.get_chat_id(email),
          text: CGI.unescape(text),
          email: email
        }
      }
    else
      return {
        status: 500,
        message: "Not sent (user doesn't registered in Bot)",
        body: {
          email: email,
          text: text
        }
      }
    end
  end
end
