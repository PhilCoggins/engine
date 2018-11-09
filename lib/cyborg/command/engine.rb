require 'optparse'
require 'cyborg/command/engine_help'
require File.expand_path("./engine_help", File.dirname(__FILE__))

options = {assets: []}

def next_arg
  if ARGV.first && !ARGV.first.match(/^-/)
    ARGV.shift
  end
end

OptionParser.new do |opts|

  options[:help] = ARGV.shift if %w(help h).include?(ARGV.first)

  if ARGV.empty?
    options[:help] = true
  else
    options[:command] = next_arg
  end

  opts.banner = Cyborg::EngineHelp.banner(options[:command])

  if %w(s server).include? options[:command]
    opts.on("-w", "--watch", "Watch assets") do |val|
      options[:watch] = true
    end
  end

  if %w(b w s build watch server).include? options[:command]
    opts.on("-j", "--js", "Build javascripts.") do |val|
      options[:select_assets] = true
      options[:js] = true
    end

    opts.on("-c", "--css", "Build css.") do |val|
      options[:select_assets] = true
      options[:css] = true
    end

    opts.on("-s", "--svg", "Build svgs.") do |val|
      options[:select_assets] = true
      options[:svg] = true
    end

    opts.on("-P", "--production", "Build assets as with production mode.") do |val|
      ENV['RAILS_ENV'] = 'production'
      options[:production] = true
    end

    opts.on("-C", "--clean", "Remove cache files before build.") do |val|
      options[:clean] = true
    end
  end

  if %w(s server).include? options[:command]
    opts.on("-p", "--port PORT", String, "serve site at port") do |val|
      options[:port] = val
    end
    
    opts.on("-b", "--bind HOST", String, "Bind to a specific host, e.g. 0.0.0.0") do |val|
      options[:host] = val
    end
  end

  opts.on("-v", "--version", "Print version") do |version|
    options[:command] = 'version'
  end

  opts.on("-h", "--help", "Print this message") do |version|
    options[:help] = opts
  end

  if options[:help]
    options[:help] = opts
  end
end.parse!

Cyborg::Command.run(options)
