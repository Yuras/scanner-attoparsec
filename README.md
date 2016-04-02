# scanner-attoparsec
Inject attoparsec parser with backtracking into non-backtracking scanner

Backtracking kills performance, so scanner package doesn't support it.
But sometimes you just need it. E.g. you have a mostly non-backtracking
parser, but a small bit of its grammar is too complex to transform it
to non-backtracking form. In that case you can inject a backtracking
attoparsec parser into otherwise non-backtracking scanner.

See also http://hackage.haskell.org/scanner
