require File.expand_path("../lib/thunder/version", __FILE__)

Gem::Specification.new do |s|
  s.version     = Thunder::VERSION

  s.name        = 'thunder'
  s.summary     = "Thunder makes command lines apps easy!"
  s.description = "Thunder does command line interfaces. Nothing more, nothing less."

  s.authors     = ["Steven Karas"]
  s.email       = 'steven.karas@gmail.com'
  s.homepage    = 'http://stevenkaras.github.com/thunder'
  s.license     = 'MIT'

  s.files       =  []
  s.files       += Dir['lib/**/*.rb', 'spec/**/*.rb']
  s.files       += Dir['[A-Z]*']

  s.bindir      = 'bin'
  s.executables = Dir['bin/*'].map { |e| File.basename(e) }
end
