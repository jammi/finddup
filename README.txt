This utility finds duplicate files. It's as simple as that.

To install finddup, you must have ruby installed, then just run this:
  gem install finddup

Usage:
Finddup by default finds files under your working directory.
If you want to search another directory, just use that as the only argument.

Output:
If there are no duplicates to find, finddup simply doesn't output anything.
While it's searching, it's updating the status line like this:
 - Scrolling throbber (of -/|\ characters) while it's reading big files.
 - A simple dot (.), when it's scanning a directory
 - An asterisk (*), when it's found a duplicate
 - An exclamation mark (!), when it's found a big file (over 2MB by default).
After the searching, it does another pass for the big files, comparing their sizes first.
Duplicates are reported in groups of two or files with the same content.
The output is delimitted by "Duplicate files:" and terminated with an extra "\n".

Homepage and source repository:
http://github.com/jammi/finddup
