# Python Subset Parser using ANTLR

Created by Andrew Hellman and Zack Murry for the CS 4450 Principles of Programming Languages course (Fall 2025) at the University of Missouri.

Group name: Bulldog Nation

# Dependencies

- python3 (tested on Python 3.13.7)
- antlr4 and python3-antlr4 (Python ANTLR bindings) for automated parser generation
- python3-graphviz for parse tree visualization

# Setup

### Generate ANTLR Python files

```bash
$ antlr4 -Dlanguage=Python3 grammar/PythonSubset.g4 -visitor -listener
```

### Create parse tree from Python file

```bash
$ python3 parser.py project_deliverable_3.py
```

# Example Parse Trees

## Simple While Loop

```python
while True:
  print('PoPL <3')
```

![while loop parse tree](examples/while_loop.png)

## Deliverable 1

![deliverable 1](examples/deliverable_1.png)

## Deliverable 2

![deliverable 2](examples/deliverable_2.png)

# Deliverable 3 (minimal, new parts only)

![deliverable 3 minimal](examples/deliverable_3_minimal.png)
