# **ELABorate**
ELABorate is a Circuit Analysis Tool capable of pure symbolic analysis, as well as partial or complete numerical evaluation. Written and run in MATLAB. ELABorate is geared towards circuit analysis and design, but has applications for any general system analysis, such as controller design.

The plan is to either move to a standalone application, if/when MATLAB coder gains support for the symbolic math toolbox, or move to Python and the Sympy library.

See the [Wiki](https://github.com/NicklasVraa/ELABorate/wiki/1.-Introduction) for a full run-down of the program.

[**Download**](https://github.com/NicklasVraa/ELABorate/raw/master/ELABorate.mltbx)


### **How is it different?**
Contrary to other circuit analysis software, like all SPICE-based programs, ELABorate does not need numerical values, and will tell you how a circuit behaves for ANY numerical value, by returning circuit equations, rather than a number. Doing symbolic calculations allow for much broader understanding of a circuit. A couple of 'symbolic-spice' [programs](https://www.egr.msu.edu/~wierzba/index_Page533.htm) have been emerging very recently, but all are in the demo stage and none seem that usable.

### **How does it work?**
Give the program a netlist, and it will return the circuit equations. These equations can be used to find any voltage or current in the circuit, which the program can also do for you, automatically. To here, to see a list of all the [features](https://github.com/NicklasVraa/ELABorate/wiki/2.-Overview-of-Features).

### **Future plans**
I have begun work on supporting non-linear components like MOSFETs and BJTs, which looks promising. I also plan to implement transfer-function-to-circuit functionality, which would make it possible to automate the process of designing circuits, given a symbolic transfer function.

---

### **Examples**
Below are links to printouts of MATLAB livescripts, that showcase some of the features of ELABorate, as it currently is.
- [Basic Circuit Analysis](https://github.com/NicklasVraa/ELABorate/blob/master/examples/pdfs/circuit_analysis.pdf)
