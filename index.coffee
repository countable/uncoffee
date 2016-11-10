
fs = require 'fs'
argv = require('minimist')(process.argv.slice(2))

coffee = require 'coffee-script'


# Get several (n) copies of a string, concatenated.
str_mult = (str, n)->
  out = ''
  while n
    out += str
    n -= 1
  out

# loop through files passed in.
for filename in argv._
  # Use synchronous version of file reader for easier debugging.
  # Performance isn't a big concern with the expected use case.
  if not /\.coffee$/.test filename
    continue
  data = fs.readFileSync filename
  out_lines = []
  lines = (''+data).split '\n'
  for line in lines
    if /\s+#/.test line
      dent = line.indexOf('#')
      out_lines.push str_mult(' ', dent) + '###'
      out_lines.push line
      out_lines.push str_mult(' ', dent) + '###'
    else
      out_lines.push line

  final = coffee.compile out_lines.join("\n"), {bare: yes}
  fs.writeFileSync filename.replace(/\.coffee$/,".js"), final