require 'trollop'

module Thunder
  class TrollopAdapter
    # @see Thunder#process_options
    def self.process_options(args, command_spec)
      return nil unless command_spec[:options]
      #TODO: fix the unspecified option bug
      command_spec[:option_processor] ||= Trollop::Parser.new do
        command_spec[:options].each do |name, option_spec|
          opt_options = {}
          description = option_spec[:desc] || ""
          type = option_spec[:type]
          type = :flag if type == Thunder::Boolean
          opt_options[:type] = type
          default_value = option_spec[:default]
          opt_options[:default] = default_value if default_value
          opt_options[:short] = "-" + option_spec[:short]

          opt name, description, opt_options
        end
      end
      command_spec[:option_processor].parse(args)
    end
  end
end
