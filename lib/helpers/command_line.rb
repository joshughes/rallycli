module Rally
  class CommandLine
    def self.set_command_options(clazz, command, config)
      clazz = Object.const_get("Rally::#{clazz.capitalize}")
      clazz.rally_methods(config)
      clazz::EDITABLE_BOOLEAN_FIELDS.each do | boolean|
        command.option "--#{boolean}", TrueClass, "Sets boolean field #{boolean} to true"
      end
      clazz::EDITABLE_TEXT_FIELDS.each do | text_field |
        command.option "--#{text_field} STRING", String, "Sets text field #{text_field}"
      end
      clazz::EDITABLE_SELECT_FIELDS.each do | select_field_name, select_field_values |
        command.option "--#{select_field_name} [TYPE]", select_field_values, "Sets select field #{select_field_values}"
      end
    end
  end
end
