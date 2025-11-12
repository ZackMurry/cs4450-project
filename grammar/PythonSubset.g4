grammar PythonSubset;

// --------------------
// Parser Rules
// --------------------

program
    : statement* EOF
    ;

statement
    : assignment
    ;

assignment
    : IDENTIFIER ASSIGN expression NEWLINE?
    | IDENTIFIER AUG_ASSIGN expression NEWLINE?
    ;

expression
    : literal
    | IDENTIFIER
    | listLiteral
    | expression op=('*' | '/' | '%') expression
    | expression op=('+' | '-') expression
    | '(' expression ')'
    ;

listLiteral
    : '[' (expression (',' expression)*)? ']'
    ;

literal
    : STRING
    | NUMBER
    | BOOL
    ;

// --------------------
// Lexer Rules
// --------------------

ASSIGN      : '=';
AUG_ASSIGN  : '+= '|'-='|'*='|'/=';
BOOL        : 'True' | 'False';

STRING
    : '"' (~["\\\r\n] | '\\' .)* '"'
    | '\'' (~['\\\r\n] | '\\' .)* '\''
    ;

NUMBER
    : DIGITS ('.' DIGITS)?
    ;

IDENTIFIER
    : [a-zA-Z_] [a-zA-Z_0-9]*
    ;

NEWLINE
    : [\r\n]+
    ;

WS
    : [ \t]+ -> skip
    ;

// --------------------
// Fragments
// --------------------

fragment DIGITS : [0-9]+ ;

