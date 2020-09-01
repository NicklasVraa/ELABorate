# **ELABorate**  <!-- omit in toc -->
A **Circuit Analysis Tool** capable of **pure symbolic analysis**, as well as partial or complete **numerical evaluation**. Written and run in **MATLAB**.

---

### **Table of Contents** <!-- omit in toc -->
- [**Description**](#description)
  - [**Features**](#features)
  - [**Project Plans**](#project-plans)
- [**Using the Matlab Package**](#using-the-matlab-package)
  - [**Examples**](#examples)

---

## **Description**
ELABorate only needs a circuit **netlist** to create a model of the circuit. This **circuit-object** can be transmuted, analyzed and its functionality visualized. The program is implemented in an object-oriented fashion for modularity and extendability.

**The program will be available in 4 versions:**
- A **Matlab package**, intended to be used with Matlab Live Scripts.\
  (Beta, ready for use)

- A **Matlab Application**, with a GUI.\
  (Alpha, in active development)

- A **Standalone Application** for Windows, Mac and Linux.\
  (When Matlab Compiler starts supporting Symbolic Toolbox)

- A **Web-app** for all browsers.\
  (When Matlab Compiler starts supporting Symbolic Toolbox)

**Requirements:**
- Matlab Symbolic Toolbox
- Matlab Control Systems Toolbox

---

### **Features**
**For circuits containing...**
- Independent voltage/current sources.
- Dependent voltage/current sources.
- Resistors, capacitors and inductors.
- Ideal operational amplifiers.

**...the program is able to...**
- Transmute the circuit, by...
  - Converting parallel and series to equivalents.
  - Shorting and opening individual elements.
  - Find AC- and DC-equivalent circuits.
  - Convert to netlist.
- Analyze the circuit, by...
  - Defining system equations using Modified Nodal Analysis.
  - Finding pure symbolic, partial or numerical expressions for...
    - Each node voltage.
    - Voltages across each element.
    - Currents through each element.
    - Impedance of each element.
  - Finding symbolic/numerical transfer function.
  - Converting transfer function to alternate forms.
- Visualize circuit behavior, by plotting...
  - Step-response.
  - Pole-zero diagram.
  - Bode diagram (amplitude and phase).
  - Nyquist diagram.

---

### **Project Plans**

**Matlab Package**
- Add class-tree to documentation.
- Function for validating netlist input.
- Adding support for non-linear elements by modelling as linear sub-circuits.
- Finding circuit stability factors.
- Thevenin and norton equivalent circuit.
- Domain conversion function.
- Identify sub-circuit patterns, such as various amplifier configurations.
- Stringing sub-circuits together.
- Drawing circuit.
- Extract netlist from image, using computer vision.

*(In order of priority)*

---

## **Using the Matlab Package**
**Step 1** -
Obtain a netlist. A netlist describes a circuit in the simplest way possible, as a text file, where each line is an element of the circuit. The netlist is easily written by hand, but is also obtainable
from all types of SPICE-software. Read up on [Netlists](https://www.cpp.edu/~prnelson/courses/ece220/220-spice-notes.pdf), if in doubt.

**Step 2** -
Load ELABorate into your MATLAB environment of choice, using whatever method, you prefer. You can also just add the program directory to the matlab path. Read up on [adding paths](https://se.mathworks.com/help/matlab/ref/addpath.html) to MATLAB, if in doubt.

**Step 3** -
Create a circuit object from your netlist file by calling the `Circuit` class constructor. The only input is the path to the file.

```matlab
myCircuit = Circuit('path-to-file.txt');
```

**Step 4** -
You are now ready to do analysis on the circuit. At any point, use the `status` method, to see what has been - and what may be done with your circuit object. Read the [manual](/Documentation/Manual.md), for a complete overview of all the program's features.

```matlab
myCircuit.status
```

The static class, `ELAB`, contain all the tools, you needed to understand your circuit. For example: to symbolically analyze the circuit - in other words - finding circuit equations, node voltages, branch currents, element voltages and element currents, you write the following.

```matlab
ELAB.analyze(myCircuit)
```

The results can be accessed through the circuit object's properties. Again, the [manual](/Documentation/Manual.md) contains descriptions of every function and property in the `ELAB` and `Circuit` classes.

```matlab
myCircuit.equations
myCircuit.symbolic_node_voltages
...
```

---

### **Examples**
