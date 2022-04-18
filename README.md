# **ELABorate**
ELABorate is a circuit analysis tool capable of pure symbolic analysis, as well as partial or complete numerical evaluation. Currently written and run in MATLAB. ELABorate is geared towards circuit analysis and design, but has applications for any general system analysis, such as controller design. The plan is to either move to a standalone application, when MATLAB coder gains support for the symbolic math toolbox, or move to Python and the SymPy library.

See the [Wiki](https://github.com/NicklasVraa/ELABorate/wiki/) for a run-down of the program's features, or check out my [bachelor's thesis](https://github.com/NicklasVraa/ELABorate/blob/master/ELABorate.pdf) for all the details.

[**Download**](https://github.com/NicklasVraa/ELABorate/raw/master/builds/ELABorate.mltbx)

### **How is it different?**
Contrary to other circuit analysis software, like all SPICE-based programs, ELABorate does not need numerical values, and will tell you how a circuit behaves for ANY numerical value, by returning circuit equations, rather than a number. Doing symbolic calculations allow for much broader understanding of a circuit. A couple of 'symbolic-spice' programs have been emerging very recently, but all are in the demo stage or abandoned and none seem that usable.

### **How does it work?**
The most basic functionality is: give the program a netlist, and it will return the circuit equations. These equations contain all the information one needs to understand the behavior of the circuit.

### **Future plans**
- Function for conversion into Thevenin/Norton equivalent circuits.
- Supporting non-linear components, like diodes, MOSFETs, BJTs using different models like small-signal, etc.
- Supporting larger structures like ideal-opamps, basic common amplifiers.
- Subcircuit functionality, where you can package a netlist as a single component to be used in other netlists.
- Transfer-function-to-circuit functionality where you define a transfer function and get a netlist in return.
- Image-to-netlist function, using MATLAB computer vision library.

### **Examples**
Below are links to handful of printouts of MATLAB livescripts, that showcase some of the features of ELABorate, as it currently is.
- [Basic Circuit Analysis](https://github.com/NicklasVraa/ELABorate/blob/master/examples/pdfs/s0_circuit_analysis_intro.pdf)
- [Simplifying circuits](https://github.com/NicklasVraa/ELABorate/blob/master/examples/pdfs/s5_circuit_simplification.pdf)
- [Mosfet amplifier modelling](https://github.com/NicklasVraa/ELABorate/blob/master/examples/pdfs/s6_mosfet_amps.pdf)
- [Transmuting systems](https://github.com/NicklasVraa/ELABorate/blob/master/examples/pdfs/transmuting_systems.pdf)
