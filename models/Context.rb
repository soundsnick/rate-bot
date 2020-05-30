require_relative "../db/ORM"

class Context
  # description: Saves, manipulates, clears bot command states
  
  @table_name = "context"

  def self.get_state(chat_id)
    ORM.get_table(@table_name)[chat_id.to_s]
  end

  def self.set_state(chat_id, command)
    ORM.set_table_item(@table_name, chat_id.to_s, command)
  end

  def self.clear_state(chat_id)
    ORM.destroy_table_item(@table_name, chat_id.to_s)
  end
end
