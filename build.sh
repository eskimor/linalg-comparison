#!/bin/bash
g++ -Icpp -c -O3 cpp/cppVersion.cpp; cp cppVersion.o cpp/
cabal build
./dist/build/linalg-comparison/linalg-comparison --output report.html +RTS -N
