#! /usr/bin/env 

fs = require 'fs'
coffee = require 'coffee-script'

module.exports = (argv0) ->
  argv = require('minimist') argv0

  # Get several (n) copies of a string, concatenated.
  str_mult = (str, n)->
    out = ''
    while n
      out += str
      n -= 1
    out

  # loop through files passed in.
  for filename in argv._
    unless argv.q
      console.log('processing ' + filename + '...')
    # Use synchronous version of file reader for easier debugging.
    # Performance isn't a big concern with the expected use case.
    if not /\.coffee$/.test filename
      continue

    data = fs.readFileSync filename
    out_lines = []
    lines = (''+data).split '\n'
    
    dent = 0
    last_dent = 0
    comment_block = []

    for line in lines
      if argv.d
        console.log '>' + line

      if /^\s*#/.test line
        if /^\s*###/.test line
          continue

        unless comment_block.length
          comment_block.push '###'
        comment_block.push line.trim()
      else
        dent_match = line.match /^(\s*)\S/
        if dent_match
          last_dent = dent
          dent = dent_match[1].length
          code = line.trim()
        else
          out_lines.push('')
          continue
        # else, and catch blocks, move comment ahead one line. TODO: improve this somehow - shouldnt move comments.
        keyword = code.split(' ')[0]

        if keyword is 'else' or keyword is 'catch' or keyword is 'case'
          cdent = last_dent        
        else
          cdent = dent
        # else, and catch blocks, use previous indent level.
        if comment_block.length
          comment_block.push '###'
          while comment_block.length
            out_lines.push str_mult(' ', cdent) + comment_block.shift()

        out_lines.push line
    
    final_cs = out_lines.join("\n")
    
    if argv.d
      console.log '--final modified coffeescript--'
      console.log final_cs
      fs.writeFileSync filename.replace(/\.coffee$/,".comments"), final_cs
    
    final = coffee.compile final_cs, {bare: yes}
    
    fs.writeFileSync filename.replace(/\.coffee$/,".js"), final