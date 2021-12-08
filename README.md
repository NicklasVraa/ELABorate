# **ELABorate**
ELABorate is a circuit analysis tool capable of pure symbolic analysis, as well as partial or complete numerical evaluation. Currently written and run in MATLAB. ELABorate is geared towards circuit analysis and design, but has applications for any general system analysis, such as controller design.

The plan is to either move to a standalone application, when MATLAB coder gains support for the symbolic math toolbox, or move to Python and the SymPy library.

See the [Wiki](https://github.com/NicklasVraa/ELABorate/wiki/) for a full run-down of the program.

[**Download**](https://github.com/NicklasVraa/ELABorate/raw/master/dist/ELABorate.mltbx)


### **How is it different?**
Contrary to other circuit analysis software, like all SPICE-based programs, ELABorate does not need numerical values, and will tell you how a circuit behaves for ANY numerical value, by returning circuit equations, rather than a number. Doing symbolic calculations allow for much broader understanding of a circuit. A couple of 'symbolic-spice' [programs](https://www.egr.msu.edu/~wierzba/index_Page533.htm) have been emerging very recently, but all are in the demo stage and none seem that usable.

### **How does it work?**
Give the program a netlist, and it will return the circuit equations. These equations can be used to find any voltage or current in the circuit, which the program can also do for you, automatically. To here, to see a list of all the [features](https://github.com/NicklasVraa/ELABorate/wiki/2.-Overview-of-Features).

### **Future plans**
- Function for converting given circuit into Thevenin/Norton equivalent circuits.
- Function for converting given circuit to AC/DC equivalents.
- Function for cleaning circuit netlists, by removing redundancies like open or shorts.
- Supporting non-linear components, like diodes, MOSFETs, BJTs using different models like small-signal, etc.
- Supporting larger structures like ideal-opamps, basic common amplifiers.
- Subcircuit functionality, where you can package a netlist as a single component to be used in other netlists.
- Transfer-function-to-circuit functionality where you define a transfer function and get a netlist in return.
- (Maybe) Image-to-netlist function, using Matlab's computer-vision library.

---

### **Examples**
Below are links to handful of printouts of MATLAB livescripts, that showcase some of the features of ELABorate, as it currently is.
- [Basic Circuit Analysis](https://github.com/NicklasVraa/ELABorate/blob/master/examples/pdfs/circuit_analysis.pdf)
- [Simplifying circuits](https://github.com/NicklasVraa/ELABorate/blob/master/examples/pdfs/simplify_circuit.pdf)
- [Mosfet amplifier modelling](https://github.com/NicklasVraa/ELABorate/blob/master/examples/pdfs/circuit_analysis.pdf)
- [Transmuting systems](https://github.com/NicklasVraa/ELABorate/blob/master/examples/pdfs/simplify_circuit.pdf)
