# uncoffee
A little utility for porting projects out of coffeescript to plain javascript. It's currently simply a coffee compiler wrapper which preserves more of the comments in coffeescript source. It's written in coffeescript so it can be tested on itself.

## usage

```
coffee index.coffee <file to convert>
```

## todo?
Furhter improving readability compared to simply compiling.
  * comments which are appended to a line of code.
  * for...in loops are awkward
  * ternary ops are overused
