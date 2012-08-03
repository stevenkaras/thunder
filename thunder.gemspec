$:.unshift File.join(File.dirname(__FILE__), "lib")
require 'thunder'

Gem::Specification.new do |s|
  s.version     = Thunder::VERSION

  s.name        = 'thunder'
  s.summary     = "Thunder makes command lines apps easy!"
  s.description = "Thor does everything and the kitchen sink. Thunder only does command line interfaces."

  s.authors     = ["Steven Karas"]
  s.email       = 'steven.karas@gmail.com'
  s.homepage    = 'http://stevenkaras.github.com'

  s.files       =  []
  s.files       += Dir['lib/**/*.rb']
  s.files       += Dir['spec/**/*.rb']
  s.files       += Dir['[A-Z]*']
  s.files       += Dir['README*']
  s.files       += Dir['CHANGELOG']

end