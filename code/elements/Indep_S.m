% Part of ELABorate™, all rights reserved.
% Auth: Nicklas Vraa

classdef Indep_S < Element
% The basis for all independent sources.
    
    properties
        anode; cathode;
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

