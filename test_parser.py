import sys
from antlr4 import *
from grammar.PythonSubsetLexer import PythonSubsetLexer
from grammar.PythonSubsetParser import PythonSubsetParser

def main(filename):
    input_stream = FileStream(filename)
    lexer = PythonSubsetLexer(input_stream)
    stream = CommonTokenStream(lexer)
    parser = PythonSubsetParser(stream)
    tree = parser.program()  # Start rule
    print(tree.toStringTree(recog=parser))  # Print parse tree

if __name__ == '__main__':
    if len(sys.argv) != 2:
        print("Usage: python test_parser.py <file.py>")
    else:
        main(sys.argv[1])

