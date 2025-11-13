grammar PythonSubset;

// Parser Rules

// Start rule
program
    : statement* EOF
    ;

// For now, the only statements are assignments
statement
    : assignment
    ;

// Assignments are either = or augmenting assignments like +=, -=, etc.
assignment
    : IDENTIFIER ASSIGN expression NEWLINE?
    | IDENTIFIER AUG_ASSIGN expression NEWLINE?
    ;

// Allow literals, idents, lists, binary operations, and parentheticals
expression
    : additiveExpr
    ;

// Two levels of precedence for binary operators (following PEMDAS)
additiveExpr
    : multiplicativeExpr (BIN_OP_LOW_PRECEDENCE multiplicativeExpr)*
    ;

multiplicativeExpr
    : signedExpr (BIN_OP_HIGH_PRECEDENCE signedExpr)*
    ;

signedExpr
    : BIN_OP_LOW_PRECEDENCE signedExpr
    | primaryExpr
    ;

primaryExpr
    : literal
    | IDENTIFIER
    | listLiteral
    | '(' expression ')'
    ;

// List literal: zero or more expressions delimited by commas
listLiteral
    : '[' (expression (',' expression)*)? ']'
    ;

// Literal is one of the lexer token types
literal
    : STRING
    | NUMBER
    | BOOL
    ;


// Lexer Rules

ASSIGN      : '=';
AUG_ASSIGN  : '+=' | '-=' | '*=' | '/=';
BOOL        : 'True' | 'False';


// We divide binary operators into high and low precedence to accurately group expressions like 1 + 2 * 3 into 1 + (2 * 3) instead of (1 + 2) * 3

BIN_OP_HIGH_PRECEDENCE
    : '*'
    | '/'
    | '%'
    ;

BIN_OP_LOW_PRECEDENCE
    : '+'
    | '-'
    ;

// Match strings: inner part is any character besides \r and \n. Also, \ is not allowed at the end of the string (since it escapes the final ")
STRING
    : '"' (~["\\\r\n] | '\\' .)* '"' // Match double quotes
    | '\'' (~['\\\r\n] | '\\' .)* '\'' // Match single quotes
    ;

// Signed integers and floats
NUMBER
    : [0-9]+ ('.' [0-9]+)?
    ;

// Must start with alphabetic character (or underscore), but can have numbers after the first char
IDENTIFIER
    : [a-zA-Z_] [a-zA-Z_0-9]*
    ;

NEWLINE
    : [\r\n]+
    ;

WS
    : [ \t]+ -> skip
    ;
