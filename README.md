# A tiny lisp interpreter

This is the smallest Lisp interpreter I've written.

## Features

- Interprets programs with the typical read-eval-print loop.
- Function definition with `(define name body)` or `(define (name arg0 ...) body)`.
- Integer, double, boolean and `cons` based list data types.
- Lists builtin functions `cons`, `car` and `cdr`.
- Conditions with `(if cond then else)` builtin function.
- Loops with conditions and recursion only.
- Standard output with `print` builtin function.
- `quote` builtin function and `'` shorthand.

```sh
./lisp < example.lisp
```

---

Copyright (c) 2020 Gonçalo Mendes Ferreira

Permission to use, copy, modify, and/or distribute this software for any purpose
with or without fee is hereby granted, provided that the above copyright notice
and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND
FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS
OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER
TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF
THIS SOFTWARE.
