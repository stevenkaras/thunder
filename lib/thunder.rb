require 'thunder/version'

# Provides a simple, yet powerful ability to quickly and easily tie Ruby methods
# with command line actions.
#
# The syntax is very similar to Thor, without the most notable limitation
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
      command_name = self.class.thunder[:default_command]
    else
      command_name = args.shift.to_sym
    end
    self.class.thunder[:commands][command_name]
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
  def self.included(base) #:nodoc:
    base.send :extend, ClassMethods
  end

  module ClassMethods

    def thunder #:nodoc:
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

    def method_added(method) #:nodoc:
      thunder[:commands][method] = {
        name: method,
        usage: thunder[:usage],
        description: thunder[:description],
        options: thunder[:options]
      }
      thunder[:usage], thunder[:description], thunder[:options] = nil
    end
    
    # Set the options processor
    #
    # @param processor [#process_options]
    def options_processor(processor)
      thunder[:options_processor] = processor
    end

    # Set the help formatter
    #
    # @param formatter [#help_list,#help_command]
    def help_formatter(formatter)
      thunder[:help_formatter] = formatter
    end

    # Set the default command.
    #
    # @param command [Symbol] the default command
    def default_command(command)
      thunder[:default_command] = command
    end

    # Describe the next method (or subcommand)
    #
    # @param usage [String] the perscribed usage of the command
    # @param description [String] a short description of what the command does
    def desc(usage, description="")
      thunder[:usage], thunder[:description] = usage, description
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