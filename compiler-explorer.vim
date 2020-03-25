
" by xolox
function! s:get_visual_selection()
  let [line_start, column_start] = getpos("'<")[1:2]
  let [line_end, column_end] = getpos("'>")[1:2]
  let lines = getline(line_start, line_end)
  if len(lines) == 0
      return ''
  endif
  let lines[-1] = lines[-1][: column_end - (&selection == 'inclusive' ? 1 : 2)]
  let lines[0] = lines[0][column_start - 1:]
  return join(lines, "\n")
endfunction

let s:compiler_explorer_std_c_hdrs = ["#include <assert.h>\r", "#include <complex.h>\r",
      \"#include <ctype.h>\r","#include <errno.h>\r","#include <fenv.h>\r","#include <float.h>\r",
      \"#include <inttypes.h>\r","#include <iso646.h>\r","#include <limits.h>\r","#include <locale.h>\r",
      \"#include <math.h>\r","#include <setjmp.h>\r","#include <signal.h>\r","#include <stdalign.h>\r",
      \"#include <stdarg.h>\r","#include <stdbool.h>\r","#include <stddef.h>\r",
      \"#include <stdint.h>\r","#include <stdio.h>\r","#include <stdlib.h>\r","#include <stdnoreturn.h>\r",
      \"#include <string.h>\r","#include <tgmath.h>\r","#include <time.h>\r","#include <uchar.h>\r",
      \"#include <wchar.h>\r","#include <wctype.h>\r"]
let s:compiler_explorer_std_cpp_hdrs = ["#include <algorithm>\r","#include <cstdlib>\r","#include <csignal>\r","#include <csetjmp>\r",
      \"#include <cstdarg>\r","#include <typeinfo>\r","#include <typeindex>\r","#include <type_traits>\r",
      \"#include <bitset>\r","#include <functional>\r","#include <utility>\r","#include <ctime>\r",
      \"#include <chrono>\r","#include <cstddef>\r","#include <initializer_list>\r","#include <tuple>\r",
      \"#include <new>\r","#include <memory>\r","#include <scoped_allocator>\r","#include <climits>\r",
      \"#include <cfloat>\r","#include <cstdint>\r","#include <cinttypes>\r","#include <limits>\r",
      \"#include <exception>\r","#include <stdexcept>\r","#include <cassert>\r","#include <system_error>\r",
      \"#include <cerrno>\r","#include <cctype>\r","#include <cwctype>\r","#include <cstring>\r",
      \"#include <cwchar>\r","#include <cuchar>\r","#include <string>\r","#include <array>\r",
      \"#include <vector>\r","#include <deque>\r","#include <list>\r","#include <forward_list>\r",
      \"#include <set>\r","#include <map>\r","#include <unordered_set>\r","#include <unordered_map>\r",
      \"#include <stack>\r","#include <queue>\r","#include <algorithm>\r","#include <iterator>\r",
      \"#include <cmath>\r","#include <complex>\r","#include <valarray>\r","#include <random>\r",
      \"#include <numeric>\r","#include <ratio>\r","#include <cfenv>\r","#include <iosfwd>\r",
      \"#include <ios>\r","#include <istream>\r","#include <ostream>\r","#include <iostream>\r",
      \"#include <fstream>\r","#include <sstream>\r","#include <iomanip>\r",
      \"#include <streambuf>\r","#include <cstdio>\r","#include <locale>\r","#include <clocale>\r",
      \"#include <codecvt>\r","#include <regex>\r","#include <atomic>\r","#include <thread>\r",
      \"#include <mutex>\r","#include <shared_mutex>\r","#include <future>\r","#include <condition_variable>\r"]
" sends visual selection to compiler exlorer and gets the asm back

" should probably change this to be the complete path and make the variable
" glboal
let s:compiler_explorer_config="/ceconfig.json"
function! s:compiler_explorer()
  let temp_file = tempname()
  if &filetype == "c"
    call writefile(s:compiler_explorer_std_c_hdrs, temp_file, "a")
  elseif &filetype == "cpp"
    call writefile(s:compiler_explorer_std_cpp_hdrs, temp_file, "a")
  endif

  let source_code = s:get_visual_selection()
  call writefile(split(substitute(source_code, "\n", "\r", "g"), "\r"), temp_file, "a")
  let current_buf_name = bufname("%")
  botright vnew
  setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile nowrap
  call setline(3,substitute(getline(2),'.','=','g'))
  execute "$read!"."node"." "."~/scripts/compiler-explorer/main.js ".temp_file. " ". getcwd(0).s:compiler_explorer_config
  setlocal nomodifiable
  set syntax=nasm
  1
endfunction
command! -complete=shellcmd -nargs=0 CompilerExplorer call s:compiler_explorer()
vmap <S-F9> :<C-U>CompilerExplorer<cr>

