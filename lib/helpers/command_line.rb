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

    def self.get_story(story, rally_cli)
      Rally::Story.new(
        Rally::Story.find_by_formattedID(story, rally_cli),
        rally_cli.config
      )
    end

    def self.story?(arg)
      arg =~ /US/
    end

    def self.task?(arg)
      arg =~ /TA/
    end
  end
end
