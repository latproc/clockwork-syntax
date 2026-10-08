" Vim syntax file
" Language:    Clockwork (latproc / iod)  --  *.cw, *.lpc
" Maintainer:  latproc
" Last change: 2026-10-08
"
" The word, operator, comment and literal sets below come from the Clockwork
" lexer, latproc/iod/src/cwlang.lpp (parser token names: cwlang.ypp).  That
" file is the authority: when the language gains or drops a word, this file
" changes with it.  tools/check-keywords.sh does the comparison mechanically:
"
"     tools/check-keywords.sh /path/to/iod/src/cwlang.lpp
"
" Clockwork keywords are upper case and case sensitive.  Lower case words
" (on, off, idle, ...) are state and option names, not keywords.

if exists("b:current_syntax")
  finish
endif

syn case match

" ---------------------------------------------------------------------------
" Keywords -- one entry per keyword rule in cwlang.lpp
" ---------------------------------------------------------------------------
syn keyword cwKeyword ABORT ABS ADC ADD AFTER ALL AND ANY ARE AS ASC
      \ ASCENDING ASSIGN AT BECOMES BEFORE BETWEEN BITSET BOARD BY CALL
      \ CATCH CHANGING CHANNEL CLASS CLEAR COMBINATION COMMAND COMMANDS
      \ COMMON CONDITION CONSTRAINT COPY COUNT CPU CREATE DAC DEC DEFAULT
      \ DEFAULTS DESC DESCENDING DESERIALISE DIFFERENCE DIGITALIN DIGITALIO
      \ DISABLE DISABLED DURING ELSE ENABLE ENABLED ENTER ENTERED ENTRIES
      \ ERROR ERRORS ETHERNET EXECUTE EXISTS EXPORT EXPORTS EXTENDS EXTRACT
      \ FAILURE FIND FIRST FORMAT FROM GLOBAL GROUP IDENTIFIER IF IGNORE
      \ IGNORES IN INC INCLUDE INCLUDES INDEX INITIAL INTERFACE IS ITEM
      \ ITEMS JSON JSON_VALUE JTAG KEY LAST LEAVE LENGTH LINKED LOAD LOCAL
      \ LOCK LOG
      \ MACHINE MACHINES MATCHES MATCHING MAX MEAN MIN MODBUS MODULE
      \ MODULES MONITORS MOVE NAME NOT OF ON OPTION OR PIN PLUGIN
      \ PROPERTIES PROPERTY PROPERTY_CHANGES PUBLISHER PUSH READONLY
      \ READWRITE RECEIVE RECEIVES REFERS REPLACE REPORTS REQUIRES RESET
      \ RESUME RETURN RO ROUTE RW SDIO SDO SEEK SELECT SEND SENDS SEPARATED
      \ SERIALISE SERIALIZE SET SHARES SHUTDOWN SIZE SORT SPI SQRT STATE
      \ STATES STATE_CHANGES SUM TAG TAKE THROTTLE THROW TIMEOUT TO TOUCH
      \ TRANSITION UART UNLOCK UPDATES USING VERSION WAIT WAITFOR WHEN
      \ WHERE WITH WITHIN

" IS NOT is a single operator token in the lexer (IS[ ]*NOT).  Both words are
" in the list above, which is as far as highlighting can take it: a keyword
" beats a match that starts in the same column.

" Type words.  cwlang.lpp spells 16BIT and 32BIT into the parser's WORD and
" DOUBLEWORD tokens, STRING into STRINGTYPE and SYMBOL into SYMBOLTYPE.
syn keyword cwType 16BIT 32BIT FLOAT FLOAT32 INTEGER STRING SYMBOL

" Run-time values supplied by the symbol table (symboltable.cpp).
syn keyword cwConstant CLOCK DAY FALSE HOUR ISOTIMESTAMP LOCALTIME MINUTE
      \ MONTH NOW RANDOM RANDOMSEED SECONDS TIMESEQ TIMESTAMP TRUE UTCTIME
      \ UTCTIMESTAMP YEAR YR

" Built-in machine classes and reserved instance and option names.  This is
" not a lexer list: it is the class registry in iod (MachineClass
" construction, the module type table in cw.cpp) plus the tokeniser's reserved
" names in symboltable.cpp and the names the standard libraries agree on.
" User-defined classes appear in the same position in the source.
syn keyword cwBuiltin ACTIVE ANALOGINPUT ANALOGOUTPUT ASSIGNED CHANNELS
      \ CLOCKWORK COMMANDCLOCK CONSTANT COUNTER COUNTERRATE CYCLE_DELAY
      \ DEBUG DIGITALLED DIGITALVALUE EMPTY ETHERCAT ETHERCAT_BUS
      \ ETHERCAT_LINKSTATUS ETHERCAT_WORKINGCOUNTER EXTERNAL FLAG HOST INIT
      \ INPUT LEDSTRIP LIST MQTTBROKER MQTTPUBLISHER MQTTSUBSCRIBER NONEMPTY
      \ OUTPUT PERSISTENT POINT POLLING_DELAY PORT PREOP PROTOCOL
      \ RATEESTIMATOR REFERENCE SDOENTRY SELF SPEEDCONTROLLER STATUS_FLAG
      \ SYSTEM SYSTEMSETTINGS TIMER TRACE VALUE VARIABLE

" PRIVATE is still lexed, but it is an error -- the lexer reports "PRIVATE
" semantics are changing.  Use LOCAL instead" and substitutes LOCAL.
syn keyword cwDeprecated PRIVATE

" ---------------------------------------------------------------------------
" Operators -- the symbol rules in cwlang.lpp.  Single characters are defined
" first so the two character operators, defined last, win at a shared position.
" ---------------------------------------------------------------------------
syn match cwOperator "[-+*/%&|^~!<>=]"
syn match cwOperator "=="
syn match cwOperator "!="
syn match cwOperator "<="
syn match cwOperator ">="
syn match cwOperator ":="
syn match cwOperator "&&"
syn match cwOperator "||"
syn match cwOperator "<<"

" ---------------------------------------------------------------------------
" Comments -- '#' to end of line, and '/* ... */' across lines
" ---------------------------------------------------------------------------
syn match  cwComment "#.*$"
syn region cwComment start="/\*" end="\*/"

" ---------------------------------------------------------------------------
" Strings, regular expression patterns and JSON expressions
" ---------------------------------------------------------------------------
syn region cwString    start=+"+ skip=+\\"+ end=+"+
syn region cwPattern   start=+`+ skip=+\\`+ end=+`+
syn match  cwJsonExpr  "\${\_[^}]*}"

" ---------------------------------------------------------------------------
" Numbers -- the cwlang.lpp hex, float and integer rules
" ---------------------------------------------------------------------------
syn match cwNumber "\v<0x[0-9a-fA-F]+>"
syn match cwNumber "\v<\d+(\.\d*)?([eE][-+]?\d{1,3})?>"

" ---------------------------------------------------------------------------
" %BEGIN_PLUGIN ... %END_PLUGIN holds C++ source.  Defined last so the region
" wins over the '%' operator at the same position.
" ---------------------------------------------------------------------------
syn region cwPlugin start="%BEGIN_PLUGIN" end="%END_PLUGIN"

" ---------------------------------------------------------------------------
" Highlight groups
" ---------------------------------------------------------------------------
hi def link cwKeyword    Keyword
hi def link cwType       Type
hi def link cwConstant   Constant
hi def link cwBuiltin    Function
hi def link cwDeprecated Error
hi def link cwOperator   Operator
hi def link cwComment    Comment
hi def link cwString     String
hi def link cwPattern    String
hi def link cwJsonExpr   Special
hi def link cwNumber     Number
hi def link cwPlugin     PreProc

let b:current_syntax = "clockwork"
