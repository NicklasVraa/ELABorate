% Part of ELABorate, all rights reserved.
% Auth: Nicklas Vraa

classdef (Abstract) Dep_CC < Dep_S
% The abstract basis for all dependent current-controlled sources.
    
    properties
        num_terminals = 2;
        ctrl_anode; ctrl_cathode;
    end
    
    methods
        function obj = Dep_CC(id, anode, cathode, ctrl_anode)
        % Dependent-current-controlled-source object constructor.

            obj.id = id;
            obj.anode = anode;
            obj.cathode = cathode;
            obj.ctrl_anode = ctrl_anode;
            obj.terminals = [obj.anode, obj.cathode];
        end

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