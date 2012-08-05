Thunder
=======
Ruby gem for quick and easy command line interfaces

Usage
-----
see 'sample' for a quick overview of all features

Philosophy
----------
The command line is the most basic interface we have with a computer. It makes sense that we should invest as much time and effort as possible to build tools to work with the command line, and tie into code we write as quickly as possible. Sadly, this has not taken place as much as one would expect. This library steps up to bridge the admittedly small gap between your standard shell and ruby code.

While this is possible, and even easy using existing libraries, they either violate the principle of locality, or provide too many services.

The overarching philosophy here is that a library should do one or two things, and do them extremely well.

Goals
-----
Provide a simple, DRY syntatic sugar library that provides the necessary services to create command line mappings to ruby methods. It will not provide any other services.

Phase 1: call a method from the command line
Phase 2: provide options and arguments 
Phase 3: provide help/banner formatter
Phase 4: provide yardoc integration
Phase 5: provide a bash-completion script.
Phase 6: ???
Phase 7: Profit!

Development
-----------
If you'd like to contribute, fork, commit, and request a pull. I'll get around to it. No special dependencies, or anything fancy

License
-------
MIT License