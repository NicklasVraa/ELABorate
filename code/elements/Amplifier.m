% Part of ELABorate™, all rights reserved.
% Auth: Nicklas Vraa

classdef Amplifier < Element
% The basis for all transistor variations (BJT, MOSFET).
    
    properties
        gain; gain_val;
        num_terminals = 3;
    end
end

