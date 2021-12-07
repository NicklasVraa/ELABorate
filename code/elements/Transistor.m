% Part of ELABorate™, all rights reserved.
% Auth: Nicklas Vraa

classdef Transistor < Element
% The basis for all transistor variations (BJT, MOSFET).
    
    properties
        gain; gain_val;
        num_terminals = 3;
    end
    
    methods(Abstract)
        internal(obj)
    end
end

