module Thunder
  # Provides an easy to parse help formatter
  class DefaultHelp
    class << self

      # @see Thunder#help_command(command_spec)
      def help_command(command_spec)
        preamble = determine_preamble
        #TODO: add options to output
        output = <<-EOS
Usage:
  #{preamble} #{command_spec[:usage]}

#{command_spec[:description]}
#{command_spec[:long_description]}
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
      def render_table(data, separator = "#")
        column_width = data.group_by do |data|
          data.first.size
        end.max.first
        "".tap do |output|
          data.each do |line|
            output << "%-#{column_width}s #{separator} %s\n" % line
          end
        end
      end
    end
  end
end