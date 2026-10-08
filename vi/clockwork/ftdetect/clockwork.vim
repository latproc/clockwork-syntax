" Clockwork sources: *.cw and *.lpc.
"
" There is no file type in Vim for the latproc Clockwork language, so the two
" extensions need different treatment.

augroup clockwork_filetype
  autocmd!

  " *.cw is not claimed by anything else, so setfiletype is enough: a file
  " type another rule already decided is left alone.
  autocmd BufNewFile,BufRead *.cw setfiletype clockwork

  " *.lpc is claimed by Vim's own filetype.vim --
  "     au BufNewFile,BufRead *.lpc,*.ulpc setf lpc
  " for the unrelated LPC (MUD) language.  That autocmd is registered before
  " this file is sourced, so it runs first and setfiletype here would be a
  " silent no-op; the file would get Vim's 'lpc' syntax instead of Clockwork.
  " Force it.
  autocmd BufNewFile,BufRead *.lpc setlocal filetype=clockwork

augroup END
