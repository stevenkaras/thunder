# Provides a simple, yet powerful ability to quickly and easily tie Ruby methods
# with command line actions.
#
# The syntax is very similar to Thor, so switching over should be extremely easy
module Thunder

  # Used to indicate a boolean true or false value for options processing
  class Boolean; end

  # Start the object as a command line program,
  # processing the given arguments and using the provided options.
  #
  # @param args [<String>] (ARGV) the command line arguments
  # @param options [{Symbol => *}] ({}) the default options to use
  def start(args = ARGV.dup, options = {})
    command_spec = determine_command(args)
    return unless command_spec

    if command_spec[:name] == :help && command_spec[:default_help]
      return get_help(args, options)
    end

    parsed_options = process_options(args, command_spec)
    options.merge!(parsed_options) if parsed_options

    return command_spec[:subcommand].start(args, options) if command_spec[:subcommand]

    args << options if parsed_options

    if command_spec[:params]
      min = command_spec[:params].count { |param| param.first == :req}
      if args.size < min
        ARGV.insert((ARGV.size - args.size) - 1, "help")
        puts help_command(command_spec)
        return
      end
      max = if command_spec[:params].map(&:first).include?(:rest)
        nil
      else
        command_spec[:params].size
      end
      if !max.nil? && args.size > max
        ARGV.insert((ARGV.size - args.size) - 1, "help")
        puts help_command(command_spec)
        return
      end
    end
    return send command_spec[:name], *args
  end

  protected
  # Determine the command to use from the given arguments
  #
  # @param args [<String>] the arguments to process
  # @return [Hash,nil] the command specification for the given arguments,
  #         or nil if there is no appropriate command
  def determine_command(args)
    if args.empty?
      return self.class.thunder[:commands][self.class.thunder[:default_command]]
    end
    command_name = args.first.to_sym
    command_spec = self.class.thunder[:commands][command_name]
    if command_spec
      args.shift
    else
      command_spec = self.class.thunder[:commands][self.class.thunder[:default_command]]
    end
    return command_spec
  end

  # Process command line options from the given argument list
  #
  # @param args [<String>] the argument list to process
  # @param command_spec [Hash] the command specification to use
  # @return [{Symbol => *},nil] the options
  def process_options(args, command_spec)
    return nil unless command_spec[:options]

    unless self.class.thunder[:options_processor]
      require File.expand_path("../thunder/options/optparse", __FILE__)
      self.class.thunder[:options_processor] = Thunder::OptParseAdapter
    end
    self.class.thunder[:options_processor].process_options(args, command_spec)
  end

  # get help on the provided subjects
  #
  # @param args [<String>] the arguments list
  # @param options [Hash] any included options
  def get_help(args, options)
    if args.empty?
      puts help_list(self.class.thunder[:commands])
    else
      puts help_command(determine_command(args))
    end
  end

  # Render a usage list of the given commands
  #
  # @param commands [<Hash>] the commands to list
  # @return [String] the rendered help
  def help_list(commands)
    self.class.get_help_formatter.help_list(commands)
  end

  # Render detailed help on a specific command
  #
  # @param command_spec [Hash] the command to render detailed help for
  # @return [String] the rendered help
  def help_command(command_spec)
    self.class.get_help_formatter.help_command(command_spec)
  end

  public
  # @api private
  # Automatically extends the singleton with {ClassMethods}
  def self.included(base)
    base.send :extend, ClassMethods
  end

  # This module provides methods for any class that includes Thunder
  module ClassMethods

    # @api private
    # Get the thunder configuration
    def thunder
      @thunder ||= {
        default_command: :help,
        commands: {
          help: {
            name: :help,
            usage: "help [COMMAND]",
            description: "list available commands or describe a specific command",
            long_description: nil,
            options: nil,
            default_help: true
          },
        }
      }
    end

    def get_help_formatter
      unless thunder[:help_formatter]
        require File.expand_path("../thunder/help/default", __FILE__)
        thunder[:help_formatter] = Thunder::DefaultHelp
      end
      thunder[:help_formatter]
    end

    # @api private
    # Registers a method as a thunder task
    def method_added(method)
      add_command(method.to_sym) do |command|
        command[:params] = instance_method(method).parameters
      end
    end

    # Set the options processor.
    #
    # @param processor [#process_options]
    def options_processor(processor)
      thunder[:options_processor] = processor
    end

    # Set the help formatter.
    #
    # @param formatter [#help_list,#help_command]
    def help_formatter(formatter)
      thunder[:help_formatter] = formatter
    end

    # Set the default command to be executed when no suitable command is found.
    #
    # @param command [Symbol] the default command
    def default_command(command)
      thunder[:default_command] = command
    end

    # Describe the next method (or subcommand). A longer description can be given
    # using the {#longdesc} command
    #
    # @param usage [String] the perscribed usage of the command
    # @param description [String] a short description of what the command does
    def desc(usage, description="")
      thunder[:usage], thunder[:description] = usage, description
    end

    # Provide a long description for the next method (or subcommand).
    #
    # @param description [String] a long description of what the command does
    def longdesc(description)
      thunder[:long_description] = description
    end

    # Define an option for the next method (or subcommand)
    #
    # @param name [Symbol,String] the long name of this option
    # @option options :short [String] the short version of the option [the first letter of the option name]
    # @option options :type [Class] the datatype of this option [Boolean]
    # @option options :desc [String] the long description of this option [""]
    # @option options :default [*] the default value
    #
    # @example
    #   option :output_file, type: String
    #
    # @example
    #   option "verbose", desc: "print extra information"
    def option(name, options={})
      name = name.to_sym
      options[:name] = name
      options[:short] ||= name[0]
      options[:type] ||= Boolean
      options[:desc] ||= ""
      thunder[:options] ||= {}
      thunder[:options][name] = options
    end

    # Define a subcommand
    #
    # @param command [Symbol,String] the command that transfers processing to the provided handler
    # @param handler [Thunder] the handler that processes the request
    def subcommand(command, handler)
      add_command(command.to_sym) do |subcommand|
        subcommand[:subcommand] = handler
      end
    end

    private
    def add_command(command, &block)
      attributes = [:usage, :description, :options, :long_description]
      return unless attributes.reduce(nil) { |a, key| a || thunder[key] }
      thunder[:commands][command] = {
        name: command,
      }
      attributes.each do |key|
        thunder[:commands][command][key] = thunder.delete(key)
      end
      if block
        if block.arity == 0
          block.call
        else
          block.call thunder[:commands][command]
        end
      end
    end
  end
end
