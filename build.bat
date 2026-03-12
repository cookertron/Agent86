@echo off
call "E:\Microsoft Visual Studio\18\Community\VC\Auxiliary\Build\vcvarsall.bat" x64
cl.exe /EHsc /O2 /std:c++17 /Fe:agent86.exe src\main.cpp src\lexer.cpp src\expr.cpp src\symtab.cpp src\encoder.cpp src\asm.cpp src\jit\emitter.cpp src\jit\decoder.cpp src\jit\dos.cpp src\jit\kbd.cpp src\jit\jit.cpp /I src
