require File.expand_path("../lib/thunder/version", __FILE__)

Gem::Specification.new do |s|
  s.version     = Thunder::VERSION

  s.name        = 'thunder'
  s.summary     = "Thunder makes command lines apps easy!"
  s.description = "Thor does everything and the kitchen sink. Thunder only does command line interfaces."

  s.authors     = ["Steven Karas"]
  s.email       = 'steven.karas@gmail.com'
  s.homepage    = 'http://stevenkaras.github.com/thunder'

  s.files       =  []
  s.files       += Dir['lib/**/*.rb', 'spec/**/*.rb']
  s.files       += Dir['[A-Z]*', 'README*', 'CHANGELOG']
end