import sys
from typing import Union
from antlr4 import FileStream, CommonTokenStream, ParserRuleContext, Token
from antlr4.Token import CommonToken
from antlr4.Lexer import TokenSource
from antlr4.tree.Tree import TerminalNodeImpl
from antlr4.tree.Trees import Trees
from grammar.PythonSubsetLexer import PythonSubsetLexer as Lexer
from grammar.PythonSubsetParser import PythonSubsetParser as Parser
from graphviz import Digraph

class IndentationTokenProcessor(TokenSource):
    def __init__(self, lexer: Lexer):
        self.lexer = lexer
        self.buffer: list[Token] = []
        self.indents = [0]
        self.pending_newline = False
        self.line = -1

    def emit(self, token):
        self.buffer.append(token)

    def nextToken(self):
        # Serve buffered tokens first
        if self.buffer:
            return self.buffer.pop(0)

        # Pull next token from the lexer
        tok = self.lexer.nextToken()
        ttype = tok.type

        # Handle EOF
        if ttype == Token.EOF:
            # Emit needed DEDENTs
            while len(self.indents) > 1:
                self.indents.pop()
                self.emit(self._make_token(Lexer.DEDENT, tok))
            self.emit(tok)
            return self.buffer.pop(0)

        # Handle \n
        if ttype == Lexer.NEWLINE:
            self.pending_newline = True
            return tok  # pass NEWLINE through as-is

        # Normal token
        if not self.pending_newline:
            return tok

        # Last token was a newline, so we need to re-compute indentation
        self.pending_newline = False

        # Use column index to find indentation
        indent = tok.column

        # Compare top of the indentation stack
        prev = self.indents[-1]

        if indent > prev:
            # INDENT
            self.indents.append(indent)
            print(f"Emitting INDENT at line {tok.line}, col {tok.column}")
            self.emit(self._make_token(Lexer.INDENT, tok))

        elif indent < prev:
            # One or more DEDENTs
            while self.indents and indent < self.indents[-1]:
                self.indents.pop()
                print(f"Emitting DEDENT at line {tok.line}, col {tok.column}")
                self.emit(self._make_token(Lexer.DEDENT, tok))
        
        if indent != prev:
            dent_token = self.buffer.pop(0)
            self.emit(tok) # buffer actual token
            return dent_token # but return indentation

        # Now emit the original token
        return tok
    
    def _make_token(self, token_type : int | None, prototype: Token):
        t = CommonToken(
            (self.lexer, self.lexer.inputStream),
            token_type,
            Token.DEFAULT_CHANNEL,
            prototype.start,
            prototype.stop,
        )
        t.text = "<<INDENT>>" if token_type == Lexer.INDENT else "<<DEDENT>>"
        t.column = 0
        return t

# Parse tree PNG visualizer using graphviz/dot
def tree_to_dot(tree, parser):
    dot = Digraph()
    counter = 0

    # Recursive DFS to add parse tree nodes to digraph
    def walk(node: Union[ParserRuleContext, TerminalNodeImpl]):
        nonlocal counter
        node_id = counter
        counter += 1

        label: str = Trees.getNodeText(node, parser.ruleNames)
        label = (label.replace('<', '&lt;')
                    .replace('>', '&gt;')
                    .replace('\r\n', '\\\\n'))
        label = label.replace('\r\n', '\\\\n')
        dot.node(str(node_id), label)
        if not isinstance(node, TerminalNodeImpl):
            for child in node.getChildren():
                child_id = walk(child)
                dot.edge(str(node_id), str(child_id))

        return node_id

    walk(tree)
    return dot

def main(filename):
    input_stream = FileStream(filename)
    lexer = Lexer(input_stream)
    stream = CommonTokenStream(IndentationTokenProcessor(lexer)) # type: ignore
    # Debug log for lexer
    stream.fill()  # force tokenization
    for t in stream.tokens:
        print(f"{t.text!r:15}  type={t.type:3}  line={t.line:3}  col={t.column:3}")
    parser = Parser(stream)
    tree = parser.program()  # Start rule
    print(tree.toStringTree(recog=parser))  # Print parse tree

    # Also save parse tree to disk as PNG
    dot = tree_to_dot(tree, parser)
    dot.render("parse_tree", format="png", cleanup=True)

if __name__ == '__main__':
    if len(sys.argv) != 2:
        print("Usage: python test_parser.py <file.py>")
    else:
        main(sys.argv[1])
