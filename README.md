# cpplint_docker

This is a project offering a minimal docker environment for linting C++ projects
with cpplint

## Description 
With this project you can lint arbitrary C++ code with cpplint. It does not 
require complex configurations. Clone the project and point it to your source 
directory. 

By default cppclint and clang-format use the Google style guide for linting and
formatting.

## Getting started

This project requires make and docker installed and configured for your user.

1. Clone the project:
```bash
git clone git@gitlab.dlr.de:csa/cpplint.git
```
2. Build the docker container:
```bash 
make build
```
3. lint a project using the provided make target:
```bash
make lint CPP_PROJECT_DIRECTORY=$(realpath ./hello_world)

=== CCLINT ===

      ✗ hello_world/hello_world.cpp
        #0: No copyright message found.  You should have a line: "Copyright [year] <Copyright Owner>"  [legal/copyright] [5]
        #3: Missing space before {  [whitespace/braces] [5]
        #3: Extra space before ( in function call  [whitespace/parens] [4]
Done processing hello_world/hello_world.cpp

      ✗ hello_world/include/hello.h
        #0: No copyright message found.  You should have a line: "Copyright [year] <Copyright Owner>"  [legal/copyright] [5]
Done processing hello_world/include/hello.h

      ✗ hello_world/src/hello.cpp
        #0: No copyright message found.  You should have a line: "Copyright [year] <Copyright Owner>"  [legal/copyright] [5]
        #4: Missing space before {  [whitespace/braces] [5]
        #5: Tab found; better to use spaces  [whitespace/tab] [1]
Done processing hello_world/src/hello.cpp

** LINT SUCCEEDED ** (0.023 seconds)


Total errors found: 7
Done.
```

### CPPLINT.cfg

Add a CPPLINT.cfg to your project source tree to modify the behavior of cpplint.
from the cpplint help:
```bash
   CPPLINT.cfg has an effect on files in the same directory and all
    sub-directories, unless overridden by a nested configuration file.
```
Go to https://github.com/cpplint/cpplint for more information on possible config
options.

### lintfix target
This project also includes clang-format to automate fixing of lint errors.
Some linting errors can be fixed automatically with clang-format. To fix fixable 
lint errors run the provided make target:
```bash
make lint CPP_PROJECT_DIRECTORY=$(realpath ./hello_world)
```
The CPP_PROJECT_DIRECTORY will be recursively searched and fixed with 
clang-format using by default the Google C++ style guild.

To use an alternate style guide please modify the .clang-format config file. 
