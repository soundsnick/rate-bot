require_relative '../models/User'
require_relative '../models/Context'

class Commands
  # description: Bot command handlers

  # /start
  def self.start(bot, message)
    text = "Этот бот позволит получать уведомления с rate-iitu.kz прямо на ваш Телеграм."
    text += "\nДля начала войдите в систему (/login)" unless User.is_authorized_username(message.chat.username)
    bot.api.send_message(chat_id: message.chat.id, text: text)
  end

  # /login
  def self.login(bot, message)
    if Context.get_state(message.chat.id) === '/login'
      params = message.text.split(':')
      if params.length >= 2
        if User.authorize(message.chat.username, message.chat.id, *params)
          bot.api.send_message(chat_id: message.chat.id, text: "Вы авторизованы!")
        else
          bot.api.send_message(chat_id: message.chat.id, text: "Введены неправильные данные!")
        end
        Context.clear_state(message.chat.id)
      else
        bot.api.send_message(chat_id: message.chat.id, text: "Введите валидные данные! (формат: Email:Password)")
      end
    else
      bot.api.send_message(chat_id: message.chat.id, text: "Отправьте адрес вашей электронной почты и пароль в формате email:password")
      Context.set_state(message.chat.id, '/login')
    end
  end

  # /gethistory
  def self.get_history(bot, message)
    if User.is_authorized_username(message.chat.username)
      history = History.get_history(message.chat.id, true)
      res = history.reduce("История уведомлений вашего аккаунта:\n"){ |accumulator, record| accumulator + History.format_history(record) }
      bot.api.send_message(chat_id: message.chat.id, text: res)
    else
      User.auth_error(bot, message.chat.id)
    end
  end

  # /error
  def self.error(bot, message)
    bot.api.send_message(chat_id: message.chat.id, text: "Такой команды нет!")
    Context.clear_state(message.chat.id)
    help(bot, message)
  end

  # /help
  def self.help(bot, message)
    help_list = "/login - Авторизоваться\n/gethistory - Получить список ваших уведомлений\n"
    bot.api.send_message(chat_id: message.chat.id, text: help_list)
  end

  # /cancel
  def self.cancel(bot, message)
    if @context = Context.get_state(message.chat.id)
      Context.clear_state(message.chat.id)
      bot.api.send_message(chat_id: message.chat.id, text: "Отменено.")
    else
      bot.api.send_message(chat_id: message.chat.id, text: "В данный момент ничего не выполняется.")
    end
  end
end
