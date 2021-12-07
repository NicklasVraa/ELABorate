% Part of ELABorate™, all rights reserved.
% Auth: Nicklas Vraa

classdef Resistor < Passive
    
    properties
        resistance; impedance;
    end
    
    methods
        function obj = Resistor(id, anode, cathode, resistance)
            obj.id = id;
            obj.anode = anode;
            obj.cathode = cathode;
            obj.terminals = [obj.anode, obj.cathode];
            
            if isempty(resistance)
                obj.resistance = sym(id);
            else
                obj.resistance = sym(resistance);
            end
            
            obj.impedance = obj.resistance;
        end
        
        function str = to_net(obj)
            str = sprintf('%s %s %s %s\n', ...
                obj.id, num2str(obj.anode), num2str(obj.cathode), obj.resistance);
        end
    end
end

