# License and third-party notices

Typio is a modified version of HallelujahIM by Dong Yuwei and contributors:
https://github.com/dongyuwei/hallelujahIM

HallelujahIM declares GPL v3 in its COPYING.md and LICENSE. Typio continues
under GNU GPL v3; the complete license is in LICENSE. Original authors retain
copyright in their contributions. Typio modifications by Shuqi Wang were made in
2026 (public source snapshot: 2026-10-06), including local-only
suggestions, native settings, candidate layouts, branding, icons and installers.
This source snapshot does not reproduce the private development commit history.

## marisa-trie 0.2.6

Copyright (c) 2010-2019, Susumu Yata. All rights reserved.

Source: https://github.com/s-yata/marisa-trie/tree/v0.2.6
Commit: e54f296bb52d16693931c8b963744931ef1e37f7

The public headers, library implementation and dictionary command-line tools
are vendored under vendor/marisa-trie. The complete upstream license is in
vendor/marisa-trie/COPYING.md. This distribution uses the BSD 2-clause option.
The universal static library is rebuilt from that source with
scripts/build-marisa.sh, targeting macOS 11.0 on arm64 and x86_64.

## NSScreen PointConversion

Created by Oscar Del Ben; original files retain the notice
"Copyright 2011 DibiStore. All rights reserved."
Source: https://github.com/oscardelben/NSScreen-PointConversion
The upstream README states "License: MIT".

MIT License

Copyright (c) 2011 Oscar Del Ben / DibiStore

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

## Dictionary

The dictionary assets were inherited from HallelujahIM's GPL v3 distribution,
with Typio additions. Its README identifies Peter Norvig's Google Web corpus
word counts as the underlying source: https://norvig.com/ngrams/
The MIT notice on that page applies to code; this project does not assert a
separate MIT license for the corpus data.

The original upstream dictionary paths are dictionary/google_227800_words.bin,
dictionary/google_227800_words.json and dictionary/google_227800_words.txt.
Typio's word list is exported from its shipped trie and contains 227,804 keys.
The JSON contains frequencies, including Typio additions. Rebuilding the trie
may change its byte representation without changing the set of words.

SHA-256 of the inherited Typio 1.1.2 assets before this publication cleanup:

- google_227800_words.bin: 67fc529b693802c5324805876535c5563601dfcef92e23a6fef0945dba3d8c9f
- word_frequency.json: 28c893702782a986a93c00986bf07b10112715197b172ba134b21ad9a00b8c1d

See resources/dictionary/build-binary-trie.sh to rebuild from the supplied word
list using the vendored tools.
