" http://learnvimscriptthehardway.stevelosh.com/chapters/45.html
"
if exists("b:current_syntax")
	finish
endif

syntax keyword cwKeyword DEFAULTS MACHINE
syntax keyword cwKeyword INITIAL STATE ENTER NUMBER SEPARATOR 
syntax keyword cwKeyword SET LOG 
syntax keyword cwKeyword PROPERTY DEFINE COLLECT FROM TEST EXECUTE SPAWN RUN
syntax keyword cwKeyword CALL TRIM LINE OF USING MATCH IN REPLACE WITH INTERPRET
syntax keyword cwKeyword COMMA BEGINPROP ENDPROP PROPSEP STATEMACHINE WHEN TO RECEIVE
syntax keyword cwKeyword DURING WAIT WAITFOR TRANSITION TAG INC DEC BY CONCAT
syntax keyword cwKeyword SEND CONDITION INITSTATE IF ELSE ENABLE DISABLE BECOMES
syntax keyword cwKeyword GLOBAL GROUP OPTION LOCK UNLOCK ON RESUME AT SHUTDOWN COMMAND
syntax keyword cwKeyword EXPORT READONLY READWRITE WORD DOUBLEWORD STRINGTYPE
syntax keyword cwKeyword STATES MATCHES COMMANDS COPY EXTRACT ALL REQUIRES
syntax keyword cwKeyword WHERE ROUTE ANY ARE COUNT SELECT TAKE LENGTH
syntax keyword cwKeyword INCLUDES INCLUDE CREATE BITSET PROPERTIES ENTRIES SORT
syntax keyword cwKeyword ENABLED DISABLED SIZE ITEM FIRST LAST
syntax keyword cwKeyword COMMON BETWEEN DIFFERENCE COMBINATION CLEAR
syntax keyword cwKeyword LEAVE ASSIGN WITHIN PUSH MOVE ITEMS PLUGIN
syntax keyword cwKeyword CHANNEL IDENTIFIER VERSION SHARES MONITORS UPDATES SENDS RECEIVES
syntax keyword cwKeyword INTERFACE EXTENDS KEY MACHINES MATCHING NAME EXPORTS
syntax keyword cwKeyword CONSTRAINT IGNORE IGNORES THROTTLE tokPUBLISHER EXISTS
syntax keyword cwKeyword THROW CATCH ABORT RETURN ERROR ERRORS TIMEOUT
syntax keyword cwKeyword REPORTS STATE_CHANGES PROPERTY_CHANGES MODBUS
syntax keyword cwKeyword LINKED SDO LOCAL CLASS AS INTEGER FLOAT ASINT ASFLOAT
syntax keyword cwKeyword FLOAT32 SUM ABS MIN MAX MEAN
syntax keyword cwKeyword CHANGING FAILURE ADD AFTER BEFORE
syntax keyword cwKeyword ASCENDING ASC DESCENDING DESC INDEX

syntax keyword cwBuiltin DEFAULT FLAG SYSTEMSETTINGS CLOCKWORK POINT MODULE MODULES
syntax keyword cwBuiltin STATUS_FLAG ANALOGINPUT COUNTER RATEESTIMATOR COUNTERRATE
syntax keyword cwBuiltin ANALOGOUTPUT SPEEDCONTROLLER LIST REFERENCE MQTTPUBLISHER 
syntax keyword cwBuiltin MQTTSUBSCRIBER MQTTBROKER CONDITION VARIABLE CONSTANT
syntax keyword cwBuiltin ETHERCAT_WORKINGCOUNTER ETHERCAT_LINKSTATUS ETHERCAT_BUS
syntax keyword cwBuiltin INIT ETHERCAT SDOENTRY EXTERNAL CHANNELS

syntax keyword cwBuiltin NAME HOST PORT PROTOCOL SYSTEM VALUE UP DOWN ASSIGNED EMPTY

syntax match cwOperator "\v[^a-zA-Z_]IS[^a-zA-Z_]"
syntax match cwOperator "\v[^a-zA-Z_]NOT[^a-zA-Z_]"
syntax match cwOperator "\v[^a-zA-Z_]AND[^a-zA-Z_]"
syntax match cwOperator "\v[^a-zA-Z_]OR[^a-zA-Z_]"
syntax match cwOperator "\v\%"
syntax match cwOperator "\v\*"
syntax match cwOperator "\v/"
syntax match cwOperator "\v\+"
syntax match cwOperator "\v-"
syntax match cwOperator "\v\=\="
syntax match cwOperator "\v\!\="
syntax match cwOperator "\v\:\="

syntax match cwComment "\v#.*$"
" https://blog.ostermiller.org/find-comment
syntax match cwComment "\v\/\*([^*]|[\r\n]|(\*+([^*/]|[\r\n])))*\*+/"

" syntax match cwString /'.'/hs=s+1,he=e-1
syntax region String   start=+"+  skip=+\\"+  end=+"+

highlight link cwKeyword Keyword
highlight link cwBuiltin Function
highlight link cwString String
highlight link cwComment Comment
highlight link cwOperator Operator

let b:current_syntax="clockwork"
