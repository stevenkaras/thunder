This document will document my various design decisions

Option Parsing
--------------
Rather than include option parsing as part of the Thunder Core, I farm out the work through an adapter.
The default adapter is only loaded if no other adapter is specified, and uses the ruby std-lib builtin OptParse library.

Help Formatting
---------------
Similar to option parsing in that the functionality is provided via an adapter.
The default implementation uses a style similar to rake and thor. This was chosen since it is the easiest to parse using regular expressions, barring developer error.

Subcommands
-----------
One of the stated design goals was to provide subcommand support, ala svn, git, gem and rails.
It has occured to me that as a result of the way I farm out option parsing and help formatting, this information is not passed on to the subcommand. As a result, each subcommand would need to declare which formatter to use, if the default one is not desired. This is possible to work around, but it would add an extra parameter or two to the start method, which I'd like to avoid. As there is no other way to solve this without resorting to smelly code, I'm going to put off this decision until it actually becomes relevant (it may in the future, who knows?)

Singleton vs. Instance #start()
-------------------------------
Thor runs the start through the class singleton. But it also requires you to inherit from the Thor class. This means that more complex classes cannot be turned into adhoc command line utilities, which I view as a significant limitation against the integration of command line and code. Bridging that gap is exactly what this library is supposed to do.