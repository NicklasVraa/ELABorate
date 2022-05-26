% Part of ELABorate™, all rights reserved.
% Auth: Nicklas Vraa

classdef Impedance < Element
% A generic impedance class from which the resistor, 
% capacitor and inductor inherits.
    
    properties
        impedance;
        anode; cathode;
        v_across; i_through;
        num_terminals = 2;
    end
    
    methods
        function obj = Impedance(id, anode, cathode, impedance)
            obj.id = id;
            obj.anode = anode;
            obj.cathode = cathode;
            obj.terminals = [obj.anode, obj.cathode];
            
            if isempty(impedance)
                obj.impedance = sym(id);
            else
                obj.impedance = sym(impedance);
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
        
         function str = to_net(obj)
             str = sprintf('%s %s %s %s\n', ...
                 obj.id, num2str(obj.anode), num2str(obj.cathode), ...
                 strrep(string(obj.impedance),' ',''));
         end
    end
end

