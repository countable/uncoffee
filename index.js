var argv, coffee, data, dent, filename, final, fs, i, j, len, len1, line, lines, out_lines, ref, str_mult;

fs = require('fs');

argv = require('minimist')(process.argv.slice(2));

coffee = require('coffee-script');

str_mult = function(str, n) {
  var out;
  out = '';
  while (n) {
    out += str;
    n -= 1;
  }
  return out;
};

ref = argv._;
for (i = 0, len = ref.length; i < len; i++) {
  filename = ref[i];

  /*
   * Use synchronous version of file reader for easier debugging.
   */

  /*
   * Performance isn't a big concern with the expected use case.
   */
  if (!/\.coffee$/.test(filename)) {
    continue;
  }
  data = fs.readFileSync(filename);
  out_lines = [];
  lines = ('' + data).split('\n');
  for (j = 0, len1 = lines.length; j < len1; j++) {
    line = lines[j];
    if (/\s+#/.test(line)) {
      dent = line.indexOf('#');
      out_lines.push(str_mult(' ', dent) + '###');
      out_lines.push(line);
      out_lines.push(str_mult(' ', dent) + '###');
    } else {
      out_lines.push(line);
    }
  }
  final = coffee.compile(out_lines.join("\n"), {
    bare: true
  });
  fs.writeFileSync(filename.replace(/\.coffee$/, ".js"), final);
}
