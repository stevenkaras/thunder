require 'optparse'

module Thunder
  # Provides an adapter to the optparse library included in the Ruby std-lib
  class OptParseAdapter
    # @see Thunder#process_options
    def self.process_options(args, command_spec)
      return {} unless command_spec[:options]

      options = {}
      command_spec[:options_processor] ||= OptionParser.new do |parser|
        command_spec[:options].each do |name, option_spec|
          opt = []
          opt << "-#{option_spec[:short]}"
          opt << if option_spec[:type] == Boolean
            "--[no-]#{name}"
          else
            "--#{name} [OPT]"
          end
          opt << option_spec[:type] unless option_spec[:type] == Boolean
          opt << option_spec[:desc]
          parser.on(*opt) do |value|
            options[name] = value
          end
        end
      end
      command_spec[:options_processor].parse!(args)

      # set default values
      command_spec[:options].each do |name, option_spec|
        next if options.has_key? name
        next unless option_spec[:default]
        options[name] = option_spec[:default]
      end

      return options
    end
  end
end