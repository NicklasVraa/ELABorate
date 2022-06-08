% Part of ELABorate, all rights reserved.
% Auth: Nicklas Vraa

classdef Dep_CC < Dep_S
% The basis for all dependent sources controlled by a current.
    
    properties
        num_terminals = 2;
        ctrl_anode; ctrl_cathode;
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

