# uncoffee
A little utility for porting projects out of coffeescript to plain javascript. It's currently simply a coffee compiler wrapper which preserves more of the comments in coffeescript source. It's written in coffeescript so it can be tested on itself.

The default coffee-script compiler only converts block comments to javascript comments, so single line comments (not wrapped by ###) are discarded. This wrapper simply pre-compiles your coffeescript so all comments are block comments.

## usage
Run the following to generate a filename.js file with comments preserved.
```
npm install -g uncoffee
uncoffee filename.coffee
```

To do a whole project
```
uncoffee `find . -name "*.coffee"`
```

Debug mode (tons of output, saves intermediate form in a ".comments" extension file.
```
uncoffee filename.coffee -d
```

## todo?
This script is currently only deals with a few specific cases to reduce the manual effort of porting a project out of Coffeescript. Here are some unsupported cases. Some may by easier using the actual coffeescript parser instead of parsing the code directly.
  * for...in loops are awkward and create a lot of temporary variable cruft in the compiled JS.
  * ternary ops are sometimes inserted in a really unreadable way in the complied JS.
