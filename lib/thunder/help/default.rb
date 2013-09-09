# Provides an easy to parse help formatter
class Thunder::DefaultHelp
  class << self

    # @see Thunder#help_command(command_spec)
    def help_command(command_spec)
      preamble = determine_preamble
      footer = ""
      footer << command_spec[:description] + "\n" if command_spec[:description]
      footer << command_spec[:long_description] + "\n" if command_spec[:long_description]
      footer << "\n" + format_options(command_spec[:options]) if command_spec[:options]
      output = <<-EOS
Usage:
  #{preamble} #{command_spec[:usage]}

#{footer.strip}
      EOS
      output.rstrip
    end

    # @see Thunder#help_list(commands)
    def help_list(commands)
      preamble = determine_preamble
      help = []
      commands.each do |name, command_spec|
        help << short_help(preamble, command_spec)
      end
      render_table(help)
    end

    private

    # format a set of option specs
    #
    # @param options [<Hash>] the option specs to format
    # @return [String]
    def format_options(options)
      data = []
      options.each do |name, option_spec|
        data << format_option(option_spec)
      end
      "Options:\n" + render_table(data, ": ")
    end

    # format an option
    #
    # @param option_spec [Hash] the option spec to format
    # @return [(String, String)] the formatted option and its description
    def format_option(option_spec)
      usage = "  -#{option_spec[:short]}, --#{option_spec[:name]}"
      usage << " [#{option_spec[:name].to_s.upcase}]" unless option_spec[:type] == Boolean
      return usage, option_spec[:desc]
    end

    # determine the preamble
    #
    # @return [String] the preamble
    def determine_preamble
      preamble = "#{File.basename($0)}"
      ARGV.each do |arg|
        break if arg == "help"
        preamble << " #{arg}"
      end
      preamble
    end

    # render the short help string for a command
    #
    # @param preamble [String] the preamble
    # @param command_spec [Hash]
    # @return [String] the short help string for the given command
    def short_help(preamble, command_spec)
      return "  #{preamble} #{command_spec[:usage]}", command_spec[:description]
    end

    # render a two-column table
    #
    # @param data [(String,String)]
    # @param separator [String]
    # @return [String] a two-column table
    def render_table(data, separator = " # ")
      column_width = data.group_by do |row|
        row.first.size
      end.max.first
      "".tap do |output|
        data.each do |row|
          output << "%-#{column_width}s#{separator}%s\n" % row
        end
      end
    end
  end
end
