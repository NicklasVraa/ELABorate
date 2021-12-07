% Part of ELABorate™, all rights reserved.
% Auth: Nicklas Vraa

classdef Dep_S < Element
% The basis for all dependent sources.
    
    properties
        anode; cathode;
        ctrl_anode; ctrl_cathode;
        v_across; i_through;
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

