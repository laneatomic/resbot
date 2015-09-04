#!/usr/bin/env ruby

require 'cinch'
require 'psych'

Dir[File.join(__dir__, 'plugins', '*.rb')].each { |file| require file }

plugins = []

files = Dir[File.join(__dir__, 'plugins', '*.rb')]

files.each do |file|
  plugins << Object.const_get((File.basename(file, '.rb')).capitalize)
end

config = Psych.load_file('config.yml')

bot = Cinch::Bot.new do
  configure do |c|
    c.server = config['server']
    c.channels = config['channels']
    c.nicks = config['nicks']
    c.password = config['password']
    c.prefix = config['prefix']
    c.plugins.plugins = plugins
  end

  on :private, ':die' do
    bot.quit
  end
end

bot.start
