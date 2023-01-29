% Part of ELABorate, all rights reserved.
% Auth: Nicklas Vraa

classdef (Abstract) Dep_VC < Dep_S
% The abstract basis for all dependent voltage-controlled sources.
    
    properties
        num_terminals = 4;
        ctrl_anode; ctrl_cathode;
    end
    
    methods
        function obj = Dep_VC(id, anode, cathode, ctrl_anode, ctrl_cathode)
        % Dependent-voltage-controlled-source object constructor.

            obj.id = id;
            obj.anode = anode;
            obj.cathode = cathode;
            obj.ctrl_anode = ctrl_anode;
            obj.ctrl_cathode = ctrl_cathode;
            obj.terminals = [obj.anode, obj.cathode, obj.ctrl_anode, obj.ctrl_cathode];
        end

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

