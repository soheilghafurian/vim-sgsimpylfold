" Fold-level checks for statements spanning several lines inside brackets.
" Run via test/run_tests.sh.

execute 'edit ' . expand('<sfile>:h') . '/bracket_folds.py'
set foldmethod=expr

" Line number in bracket_folds.py -> expected fold level.
"   2, 7      dedented ')' stays in f's fold
"   11, 14    multi-line string and dedented '))'
"   15        the '\\' string does not hide the ')'
"   18, 19    dedented '}'
"   25-28     multi-line def signature
"   29        one-line docstring after a multi-line signature (no fold of its own)
"   30, 33-34 'from_x=' is not an import
let s:expected = [
    \ [1, 1], [2, 2], [7, 2], [8, 1], [9, 2],
    \ [11, 2], [14, 2], [15, 2], [18, 2], [19, 2], [20, 1], [21, 2],
    \ [25, 1], [26, 1], [27, 1], [28, 1], [29, 1],
    \ [30, 1], [33, 1], [34, 1],
    \ ]
let s:checked = 0
for [s:lnum, s:level] in s:expected
  call assert_equal(s:level, foldlevel(s:lnum), 'line ' . s:lnum)
  let s:checked += 1
endfor
call assert_equal(len(s:expected), s:checked, 'not all checks ran')

" Reloading the buffer after the file changed on disk must drop the stale cache.
let s:tmp = tempname() . '.py'
call writefile(['def f():', '    pass', '', 'def g():', '    pass'], s:tmp)
execute 'edit ' . s:tmp
set foldmethod=expr
call assert_equal(1, foldlevel(4), 'before reload')
call writefile(['import os', 'import sys', 'x = 1', 'def f():', '    pass', '', 'def g():', '    pass'], s:tmp)
silent edit!
call assert_equal(1, foldlevel(7), 'g def after reload')
call assert_equal(0, foldlevel(3), 'x after reload')

call writefile(len(v:errors) ? v:errors : ['ALL TESTS PASSED'], $SIMPYLFOLD_TEST_OUT)
qa!
