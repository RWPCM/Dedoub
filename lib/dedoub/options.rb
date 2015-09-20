#!/usr/bin/env ruby

# parse command line options
# extracts requested photo file extensions
# shows help
# extracts main argument (directory to be processed)

#!/usr/bin/env ruby

require 'optparse'
require 'ostruct'
require 'pp'

module Dedoub

    class DedoubOptions
    
      DEFAULT_PHOTO_FILE_EXTENSIONS = [".jpg", ".tif", ".cr2", ".pdf", ".raw"]
    
      #
      # Return a structure describing the options.
      #
      def self.parse(args)
        # The options specified on the command line will be collected in *options*.
        # We set default values here.
        options = OpenStruct.new
        options.extensions = DEFAULT_PHOTO_FILE_EXTENSIONS
    
        opt_parser = OptionParser.new do |opts|
          opts.banner = "Usage: dedoub.rb [ options ] [directory]"
    
          opts.separator ""
          opts.separator "Specific options:"
    
          # List of arguments.
          opts.on("--list x,y,z", Array, "'list' of extensions") do |list|
            options.list = list
          end
    
          opts.separator ""
          opts.separator "Common options:"
    
          # No argument, shows at tail.  This will print an options summary.
          # Try it and see!
          opts.on_tail("-h", "--help", "Show this message") do
            puts opts
            exit
          end
    
          # Another typical switch to print the version.
          opts.on_tail("--version", "Show version") do
            puts ::Version.join('.')
            exit
          end
        end
    
        opt_parser.parse!(args)
        options
      end  # parse()
    
    end  # class DedoubOptions

    options = DedoubOptions.parse(ARGV)

    pp options
    pp ARGV

end



# -----------------------------------------------------------------------------
#require 'optparse'
#
#module Dedoub
#    class Options
#    
#        DEFAULT_PHOTO_FILE_EXTENSIONS = [".jpg", ".tif", ".cr2", ".pdf", ".raw"]
#    
#        attr_reader :directory_to_analyse
#        attr_reader :photo_file_extensions
#
#        def initialize(argv)
#            @photo_file_extensions = DEFAULT_PHOTO_FILE_EXTENSIONS.to_s
#            parse(argv)
#            @directory_to_analyse = argv
#        end
#    
#    private
#
#        def parse(argv)
#            OptionParser.new do |opts|
#                opts.banner = "Usage: dedoub [ options ] [directory]"
#                opts.on("-e", "--photo extensions", String, "Photos pictures extensions") do |ext|
#                    @photo_file_extensions = ext
#                end
#                opts.on("-h", "--help", "Show this message") do
#                    puts opts
#                    exit
#                end
#
#                begin
#                    argv = ["-h"] if argv.empty?
#                    opts.parse!(argv) # parse! is the method that deletes all options and keeps only main arg
#                rescue OptionParser::ParseError => e
#                    STDERR.puts e.message, "\n", opts
#                    exit(-1)
#                end
#            end
#        end
#    end
#end


