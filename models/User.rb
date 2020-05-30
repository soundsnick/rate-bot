require 'net/http'
require 'json'

require_relative '../db/ORM'
require_relative '../config/Settings'

class User
  # description: Saves, manipulates the user data

  @table_name = "users"

  def self.register(email, username, chat_id)
    ORM.set_table_item(@table_name, email, { "username" => username, "chat_id" => chat_id })
  end

  def self.authorize(username, chat_id, email, password)
    uri = URI("#{Settings.api['api_host']}/users/auth/#{email}/#{password}")
    res = JSON.parse(Net::HTTP.post_form(uri, 'q' => true).body)
    if res['professor'] and res['professor'] != ""
      register(email, username, chat_id)
      return true
    else
      return false
    end
  end

  def self.get_chat_id(email)
    ORM.get_table(@table_name)[email]['chat_id']
  end

  def self.get_email(chat_id)
    users_table = ORM.get_table(@table_name)
    users = users_table.select{ |user| users_table[user]["chat_id"] === chat_id }
    return (users.keys.length > 0) ? users.keys[0] : nil
  end

  def self.is_authorized_username(username)
    (ORM.get_table(@table_name).filter{ |key, value| value['username'] == username}).length > 0
  end

  def self.is_authorized_email(email)
    ORM.get_table(@table_name).keys.include?(email)
  end

  def self.auth_error(bot, chat_id)
    bot.api.send_message(chat_id: chat_id, text: "Вы не авторизовались в системе. Воспользуйтесь командой /login")
  end

end
