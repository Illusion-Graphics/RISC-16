<p align="center">
<img src="https://avatars2.githubusercontent.com/u/59974375?s=200&v=4">
</p>

# RISC-16
## What is RISC-16 core?
RISC-16 is an open source super simple 16bit cpu core built around the von Neumann architecture.
The project started as an in-between project learning exercice.  
It features the following:
* A simple reduced instruction set
* A constant time execution (4 cycles per instruction)
* Support for branching
* Stack management

## How to use
### Hardware
The project was built using [Fusesoc](https://github.com/olofk/fusesoc). For details on how to use Fusesoc, refer to the project's documentation.

The project has a dependency on [Illusion verilator test](https://github.com/Illusion-Graphics/Verilator-Test), execute the following to synchornize it:  
```fusesoc library add --sync-type git Verilator-Test https://github.com/Illusion-Graphics/Verilator-Test.git```

The core is supplied with a Verilog testbench, to execute it simply run:  
```fusesoc run --target=test Illusion:RISC16:CPU:1.0```

### Assembler
Details on the assembly language can be found in the documentation folder.

A cpu definition is supplied in the documentation folder to use with [customasm](https://github.com/hlorenzi/customasm) assembler.