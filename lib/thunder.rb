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
  # @param args [<String>] the command line arguments [ARGV]
  # @param options [{Symbol => *}] the default options to use [{}]
  def start(args=ARGV, options={})
    command_spec = determine_command(args)

    unless command_spec
      return
    end

    if command_spec[:name] == :help && command_spec[:default_help]
      return get_help(args, options)
    end

    options.merge!(process_options(args, command_spec))
    if command_spec[:subcommand]
      return command_spec[:subcommand].start(args, options)
    elsif options
      #TODO: do arity check
      return send command_spec, *args, options
    else
      #TODO: do arity check
      return send command_spec, *args
    end
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
    args.shift if command_spec
    return command_spec
  end

  # Process command line options from the given argument list
  #
  # @param args [<String>] the argument list to process
  # @param command_spec [Hash] the command specification to use
  # @return [{Symbol => *}] the options
  def process_options(args, command_spec)
    return nil unless command_spec[:options]

    unless self.class.thunder[:options_processor]
      require 'thunder/options/optparse'
      self.class.thunder[:options_processor] = Thunder::OptParseAdapter
    end
    self.class.thunder[:options_processor].process_options(args, command_spec)
  end

  # get help on the provided subjects
  #
  # @param args [<String>] the arguments list
  # @param options [Hash] any included options
  def get_help(args, options)
    unless self.class.thunder[:help_formatter]
      require 'thunder/help/default'
      self.class.thunder[:help_formatter] = Thunder::DefaultHelp
    end
    if args.size == 0
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
    self.class.thunder[:help_formatter].help_list(commands)
  end

  # Render detailed help on a specific command
  #
  # @param command_spec [Hash] the command to render detailed help for
  # @return [String] the rendered help
  def help_command(command_spec)
    self.class.thunder[:help_formatter].help_command(command_spec)
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
            options: nil,
            default_help: true
          },
        }
      }
    end

    # @api private
    # Registers a method as a thunder task
    def method_added(method)
      attributes = [:usage, :description, :options, :long_description]
      return unless attributes.reduce { |a, key| a || thunder[key] }
      thunder[:commands][method] = {
        name: method,
      }
      attributes.each do |key|
        thunder[:commands][method][key] = thunder[key]
        thunder[key] = nil
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
    #
    # @example
    #   option :output_file, type: String
    #
    # @example
    #   option "verbose", desc: "print extra information"
    def option(name, options={})
    #TODO: have this generate YARDoc for the option (as it should match a method option)
      name = name.to_sym
      options[:name] = name
      options[:short] ||= name[0]
      options[:type] ||= Boolean
      options[:description] ||= ""
      thunder[:options] ||= {}
      thunder[:options][name] = options
    end

    # Define a subcommand
    #
    # @param command [String] the command that transfers processing to the provided handler
    # @param handler [Thunder] the handler that processes the request
    def subcommand(command, handler)
      method_added(command)
      thunder[:commands][command][:subcommand] = handler
    end

  end
end