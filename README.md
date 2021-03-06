[Thunder](http://stevenkaras.github.com/thunder)
=======
Ruby gem for quick and easy command line interfaces

[![Gem Version](https://badge.fury.io/rb/thunder.png)](http://badge.fury.io/rb/thunder)
[![Code Climate](https://codeclimate.com/github/stevenkaras/thunder.png)](https://codeclimate.com/github/stevenkaras/thunder)

Usage
-----

    gem install thunder

or if you're running ruby 1.9.3:

    gem install thunder-1.9.3

or if you're running [ruby 1.8.7](http://www.ruby-lang.org/en/news/2011/10/06/plans-for-1-8-7):

    gem install thunder-1.8.7

see '[sample](http://github.com/stevenkaras/thunder/blob/master/sample)' for a quick overview of all features

Philosophy
----------
The command line is the most basic interface we have with a computer. It makes sense that we should invest as much time and effort as possible to build tools to work with the command line, and tie into code we write as quickly as possible. Sadly, this has not taken place as much as one would expect. This library steps up to bridge the admittedly small gap between your standard shell and ruby code.

While this is possible, and even easy using existing libraries, they either violate the principle of locality, or provide too many services.

The overarching philosophy here is that a library should do one or two things, and do them extremely well.

Goals
-----
Provide a simple, DRY syntatic sugar library that provides the necessary services to create command line mappings to ruby methods. It will not provide any other services.

Notable features as of the current release:

  * options parsing for commands
  * default commands
  * subcommands (ala git)
  * integrated help system
  * bash completion script generator

Development
-----------
If you'd like to contribute, fork, commit, and request a pull. I'll get around to it. No special dependencies, or anything fancy

License
-------
MIT License
