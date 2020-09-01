<!-- Copyright, Nicklas Vraa -->
# **The ELABorate Manual** <!-- omit in toc -->

## **Table of Contents** <!-- omit in toc -->
- [**1. Classes**](#1-classes)
  - [**1.1. `ELAB`**](#11-elab)
    - [**1.1.1. `Transmuter`**](#111-transmuter)
    - [**1.1.2. `Analyzer`**](#112-analyzer)
    - [**1.1.3. `Visualizer`**](#113-visualizer)
  - [**1.2. `Circuit`**](#12-circuit)
  - [**1.3. `Element`**](#13-element)
- [**2. How to use ELABorate**](#2-how-to-use-elaborate)

---

## **1. Classes**
In this section, the classes comprising the ELABorate program, is presented.

### **1.1. `ELAB`**
This class inherits all functionality from the classes `Analyzer`, `Transmuter` and `Visualizer`, which all contain exclusively static methods and each having only the methods, which fit under their respective names. 'ELAB' and 'Circuit' are the *only* classes, the user have to deal with.

---

#### **1.1.1. `Transmuter`**
A collection of functions, specifically for safely altering the circuit object or even converting the circuit to another form.
- `simplify()` \
  Combines parallel and series elements, adds them to the circuit object, then removes the old elements, thereby reducing the number of elements comprising the circuit.

- `model()` \
  Replaces a given transistor with a corresponding sub-circuit, modelling the behavior of the transistor, thereby making it possible to do linear analysis.

---

#### **1.1.2. `Analyzer`**
A collection of functions designed to facilitate symbolic and numerical analysis of a given circuit object.
- `analyze(circuit, signal_type)` \
  Defines a system of equations, which describes the circuit, using *Modified Nodal Analysis*. The result of solving the system, is a list of node voltages and source currents. Once run, this function updates the given `circuit` object with the discovered information. The `signal_type` is either 'AC' or 'DC'.

- `numerical()` \
  Evaluates the circuit numerically, *if* the circuit has been symbolically analyzed, and *if* any numerical element information was given in the netlist file, when the circuit object was constructed. The numerical evaluation will be partial, if any information is missing.

- `transfer(input, output, numerical)` \
  Returns the transfer function, that describes the AC-response of the circuit, at different frequencies. The boolean value `numerical`, decides if the transfer function is found as symbolic or numerical. Only the numerical transfer function can be plotted.

---

#### **1.1.3. `Visualizer`**
A collection of visualization- and graphing-functionality, specifically designed to further the user's understanding of a given circuit object.
- `response()` \
  Plots circuit step-response, if the numerical transfer function has been found, and saves graph-data to the circuit object.

- `zero_pole()` \
  Returns the zeros and poles of the circuit transfer function, along with a printable zero-pole-plot, if the numerical transfer function has been found. It also saves graph-data to the circuit object.

- `bode()` \
  Bode-plots the circuit transfer function, showing amplitude-frequency- and phase-frequency-relationships, if the numerical transfer function has been found. It also saves graph-data to the circuit object.

- `nyquist()` \
  Nyquist-plots the circuit transfer function, if the numerical transfer function has been found. It also saves graph-data to the circuit object.

---

### **1.2. `Circuit`**
The class modelling a circuit. The circuit-object contains the circuit's properties, like arrays of circuit elements, arranged by type.
- `get_netlist()` \
  Returns string representation of the circuit-object.

- `status()` \
  Prints the status of the circuit object.

---

### **1.3. `Element`**
This is the base class for all circuit elements. It's the class on top of which, all other circuit elements classes, are built. Whatever the element class contains, is inherited by specific circuit elements classes. The user does not ever have to deal with the 'Element' class or any of its subclasses, if you construct circuits through the 'Circuit' class.

It contains only abstract functions and basic properties. It inherits from 'handle' and 'mixin.heterogeneous', which makes it possible for subclasses to share array structures.

- `Indep_S` \
  Basis for all independent sources: `Indep_VS` and `Indep_IS`.

- `Passive` \
  Basis for all passive elements: `Resistor`, `Inductor` and `Capacitor`.

- `Dep_S` \
  Basis for all dependent/controlled sources: `VCVS`, `VCCS`, `CCVS`, and `CCCS`.

- `Transistor` \
  Basis for all transistor variations: `BJT` and `MOSFET`.

- `Amplifier` \
  Basis for all amplifier elements: `Ideal_OpAmp`.

---

## **2. How to use ELABorate**
In this section, the classes comprising the ELABorate program, is presented.
