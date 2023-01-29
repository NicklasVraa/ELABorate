% Part of ELABorate, all rights reserved.
% Auth: Nicklas Vraa

classdef (Abstract) Indep_S < Element
% The abstract basis for all independent sources. Should never
% be constructed directly, but through its sub-classes.
    
    properties
        is_AC;
        v_across; i_through;
        anode; cathode;
        num_terminals = 2;       
    end
    
    methods
        function obj = Indep_S(id, anode, cathode, type)
        % Independant-voltage-source object constructor.
            
            obj.id = id;
            obj.anode = anode;
            obj.cathode = cathode;
            obj.terminals = [obj.anode, obj.cathode];
            
            if strcmpi(type, 'AC')
                obj.is_AC = 1;
            elseif strcmpi(type, 'DC')
                obj.is_AC = 0;
            else
                error("Invalid type. Use 'AC' or 'DC'.");
            end
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

