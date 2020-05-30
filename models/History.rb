require 'date'
require 'cgi'

require_relative "../db/ORM"
require_relative "./User"

class History
  # description: Saves, manipulates the notification data

  @table_name = "history"

  def self.get_history(email, by_chat_id = false)
    if by_chat_id
      email = User.get_email(email)
    end

    if User.is_authorized_email(email)
      history = ORM.get_table(@table_name)
      if history.keys.include?(email)
        return history[email]
      else
        ORM.set_table_item(@table_name, email, [])
        return []
      end
    else
      return false
    end
  end

  def self.add(email, text)
    if @history = get_history(email)
      @history << { "text" => CGI.unescape(text), "created_at" => DateTime.now }
      ORM.set_table_item(@table_name, email, @history)
      return true
    else
      return false
    end
  end

  def self.format_history(record)
    "#{record["text"]} | #{DateTime.parse(record["created_at"]).strftime("%d.%m.%Y %H:%M")}\n"
  end
end
