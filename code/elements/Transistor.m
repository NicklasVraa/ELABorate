% Part of ELABorate, all rights reserved.
% Auth: Nicklas Vraa

classdef (Abstract) Transistor < Element
% The abstract basis for all transistor variations.
    
    properties
        gain; gain_val;
        num_terminals = 3;
    end
    
    methods(Abstract)
        internal(obj)
    end
end

