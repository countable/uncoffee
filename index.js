var coffee, fs;

fs = require('fs');


/*
 * a very basic single line comment
 */

coffee = require('coffee-script');


/*
 *
 * multiline unwrapped comment.
 *
 */

module.exports = function(argv0) {
  var argv, cdent, code, comment_block, data, dent, dent_match, filename, final, final_cs, i, in_multiline_comment, j, keyword, last_dent, len, len1, line, line_num, lines, out_lines, ref, results, str_mult;
  argv = require('minimist')(argv0);

  /*
   * Get several (n) copies of a string, concatenated.
   */
  str_mult = function(str, n) {
    var out;
    out = '';
    while (n) {
      out += str;
      n -= 1;
    }
    return out;
  };

  /*
   * multiline wrapped comment
   * loop through files passed in.
   */
  ref = argv._;
  results = [];
  for (i = 0, len = ref.length; i < len; i++) {
    filename = ref[i];
    if (!argv.q) {
      console.log('processing ' + filename + '...');
    }
    if (!/\.coffee$/.test(filename)) {
      continue;
    }
    data = fs.readFileSync(filename);
    out_lines = [];
    lines = ('' + data).split('\n');
    dent = 0;
    last_dent = 0;
    comment_block = [];
    in_multiline_comment = false;
    line_num = 0;
    for (j = 0, len1 = lines.length; j < len1; j++) {
      line = lines[j];
      line_num += 1;
      if (argv.d) {
        console.log('>' + line);
      }
      if (line_num === 1 && line.charAt(0) === '#') {
        out_lines.push(line);
        continue;
      }
      if (line.indexOf("##" + "#") > -1) {
        if (in_multiline_comment) {
          out_lines.push(line);
          continue;
        }
        in_multiline_comment = !in_multiline_comment;
      }
      if (in_multiline_comment) {
        out_lines.push(line);
        continue;
      }
      if (/^\s*#/.test(line)) {
        if (line.indexOf("##" + "#") === -1) {
          if (!comment_block.length) {
            comment_block.push('#' + '##');
          }
          comment_block.push(line.trim());
        }
      } else {
        dent_match = line.match(/^(\s*)\S/);
        if (dent_match) {
          last_dent = dent;
          dent = dent_match[1].length;
          code = line.trim();
        } else {
          out_lines.push('');
          continue;
        }
        keyword = code.split(' ')[0];
        if (keyword === ('el' + 'se') || keyword === ('ca' + 'tch') || keyword === ('ca' + 'se')) {
          cdent = last_dent;
        } else {
          cdent = dent;
        }
        if (comment_block.length) {
          comment_block.push('###');
          while (comment_block.length) {
            out_lines.push(str_mult(' ', cdent) + comment_block.shift());
          }
        }

        /*
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
         */
        out_lines.push(line);
      }
    }
    final_cs = out_lines.join("\n");
    if (argv.d) {
      console.log('--final modified coffeescript--');
      console.log(final_cs);
      fs.writeFileSync(filename.replace(/\.coffee$/, ".comments"), final_cs);
    }
    final = coffee.compile(final_cs, {
      bare: true
    });
    results.push(fs.writeFileSync(filename.replace(/\.coffee$/, ".js"), final));
  }
  return results;
};
