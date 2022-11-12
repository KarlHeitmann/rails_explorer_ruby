# frozen_string_literal: true

require 'tty-option'
class Command
  include TTY::Option

  usage do
    program 'rails_explorer'

    command 'run'

    desc 'Run a command in a new container'

    example 'Set working directory (-w)',
            '  $ dock run -w /path/to/dir/ ubuntu pwd'

    example <<~EXAMPLE
      Mount volume
        $ dock run -v `pwd`:`pwd` -w `pwd` ubuntu pwd
    EXAMPLE
  end

  argument :search_term do
    required
    desc 'Search term'
  end

  argument :path do
    optional
    desc 'Search term'
  end

  argument :command do
    optional
    desc 'The command to run inside the image'
  end

  keyword :spanlines do
    default "2"
    desc 'Prefix to erase on files window'
  end

  keyword :prefix do
    default ''
    desc 'Prefix to erase on files window'
  end

  keyword :restart do
    default 'no'
    permit %w[no on-failure always unless-stopped]
    desc 'Restart policy to apply when a container exits'
  end

  flag :quick do
    short '-q'
    long '--quick'
    desc 'Quick run'
  end

  flag :help do
    short '-h'
    long '--help'
    desc 'Print usage'
  end

  flag :autopilot do
    short '-a'
    long '--autopilot'
    desc 'Starts in autopilot'
  end

  option :auto do
    required
    long '--auto string'
    desc 'Assign a name to the container'
  end

  option :port do
    arity one_or_more
    short '-p'
    long '--publish list'
    convert :list
    desc "Publish a container's port(s) to the host"
  end

  def run
    if params[:help]
      print help
      exit
    else
      pp params.to_h
    end
  end
end
