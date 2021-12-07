% Part of ELABorate™, all rights reserved.
% Auth: Nicklas Vraa

classdef Passive < Element
% The basis for the resistor, inductor, and capacitor.
    
    properties
        anode; cathode;
        v_across; i_through;
        num_terminals = 2;
    end
    
    methods
        function bools = is_connected(obj, node)
            bools = [obj.anode == node, obj.cathode == node];
        end
        
        function update_terminals(obj, index, value)
            obj.terminals(index) = value;
            obj.anode = obj.terminals(1);
            obj.cathode = obj.terminals(2);
        end
    end
end

