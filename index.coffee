#! /usr/bin/env 

fs = require 'fs'

# a very basic single line comment
coffee = require 'coffee-script'

#
# multiline unwrapped comment.
#
module.exports = (argv0) -> # an inline comment.
  argv = require('minimist') argv0

  # Get several (n) copies of a string, concatenated.
  str_mult = (str, n)->
    out = ''# another inline comment
    while n
      out += str
      n -= 1
    out

  ###
  # multiline wrapped comment
  # loop through files passed in.
  ###
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
    in_multiline_comment = false
    line_num = 0

    for line in lines
      line_num += 1

      if argv.d
        console.log '>' + line

      # skip the shebang line.
      if line_num is 1 and line.charAt(0) is '#'
        out_lines.push line
        continue

      # First of all, completely ignore existing multiline comments - pass them through.
      if line.indexOf("##"+"#") > -1
        if in_multiline_comment # Final one.
          out_lines.push line
        in_multiline_comment = not in_multiline_comment

      if in_multiline_comment
        out_lines.push line
        continue

      if /^\s*#/.test line
        if line.indexOf("##"+"#") is -1
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

        if keyword is ('el' + 'se') or keyword is ('ca' + 'tch') or keyword is ('ca' + 'se')
          cdent = last_dent        
        else
          cdent = dent

        # else, and catch blocks, use previous indent level.
        if comment_block.length
          comment_block.push '###'
          console.log(comment_block)
          while comment_block.length
            out_lines.push str_mult(' ', cdent) + comment_block.shift()

        # eol comments.
        ###
        hash_pos = line.indexOf '#'
        if hash_pos > -1
          code_part = line.substr 0,hash_pos
          num_quotes = (code_part.match(/"/g) || []).length
          if 0 is num_quotes % 2
            num_quotes = (code_part.match(/'/g) || []).length
            if 0 is num_quotes % 2
              out_lines.push str_mult(' ', dent) + "##" + "#"
              out_lines.push str_mult(' ', dent) + line.substr(hash_pos)
              out_lines.push str_mult(' ', dent) + "##" + "#"
        ###


        out_lines.push line
    
    final_cs = out_lines.join("\n")
    
    if argv.d
      console.log '--final modified coffeescript--'
      console.log final_cs
      fs.writeFileSync filename.replace(/\.coffee$/,".comments"), final_cs
    
    final = coffee.compile final_cs, {bare: yes}
    
    fs.writeFileSync filename.replace(/\.coffee$/,".js"), final