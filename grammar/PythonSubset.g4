grammar PythonSubset;

// Parser Rules

// Start rule
program
    : statement* EOF
    ;

// Everything is a statement, including blank lines
statement
    : assignment
    | if_statement
    | while_statement
    | for_statement
    | expression
    | NEWLINE
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
    | functionCall
    | listLiteral
    | '(' condition ')'
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

if_statement
    : IF condition COLON NEWLINE block
      ( ELIF condition COLON NEWLINE block )*
      ( ELSE COLON NEWLINE block )?
    ;

while_statement
    : WHILE condition COLON NEWLINE block
    ;

for_statement
    : FOR IDENTIFIER IN expression COLON NEWLINE block
    ;

block
    : INDENT statement+ DEDENT
    ;

condition
    : orExpr
    ;

orExpr
    : andExpr (OR andExpr)*
    ;

andExpr
    : notExpr (AND notExpr)*
    ;

notExpr
    : (NOT)* comparisonExpr
    ;

comparisonExpr
    : additiveExpr (COMP_OP additiveExpr)?
    ;

functionCall
    : IDENTIFIER functionCallSuffix?
    ;

// Function call syntax is IDENT([expression[, expression]*]?)
functionCallSuffix
    : '(' (expression (',' expression)*)? ')'
    ;

// Lexer Rules

ASSIGN      : '=';
COLON       : ':';
AUG_ASSIGN  : '+=' | '-=' | '*=' | '/=';
BOOL        : 'True' | 'False';
COMP_OP     : '==' | '!=' | '<' | '<=' | '>' | '>=';

// Keywords

IF      : 'if';
ELIF    : 'elif';
ELSE    : 'else';
WHILE    : 'while';
FOR    : 'for';
IN    : 'in';

// Logical operations

AND : 'and';
OR  : 'or';
NOT : 'not';


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

// Comments (skip them)

LINE_COMMENT
    : '#' ~[\r\n]* -> skip
    ;

// ''' multiline comments
// Using non-greedy Kleene star (*?) to match as few characters as possible
MULTILINE_COMMENT_SINGLE
    : '\'\'\'' ( . )*? '\'\'\'' -> skip
    ;

// """ multiline comments using non-greedy Kleene stars
MULTILINE_COMMENT_DOUBLE
    : '"""' ( .)*? '"""' -> skip
    ;


// Special (indentation)
INDENT  : '<<INDENT>>';
DEDENT  : '<<DEDENT>>';
