% Part of ELABorate, all rights reserved.
% Auth: Nicklas Vraa

classdef Dep_VC < Dep_S
% The basis for all dependent sources controlled by a voltage.
    
    properties
        num_terminals = 4;
        ctrl_anode; ctrl_cathode;
    end
    
    methods
        function bools = is_connected(obj, node)
            bools = [obj.anode == node, obj.cathode == node, ...
                     obj.ctrl_anode == node, obj.ctrl_cathode == node];
        end
        
        function update_terminals(obj, index, value)
            obj.terminals(index) = value;
            obj.anode = obj.terminals(1);
            obj.cathode = obj.terminals(2);
            obj.ctrl_anode = obj.terminals(3);
            obj.ctrl_cathode = obj.terminals(4);
        end
    end
end

