% Part of ELABorate™, all rights reserved.
% Auth: Nicklas Vraa

classdef Capacitor < Passive
    
    properties
        capacitance; impedance;
    end
    
    methods
        function obj = Capacitor(id, anode, cathode, capacitance)
            obj.id = id;
            obj.anode = anode;
            obj.cathode = cathode;
            obj.terminals = [obj.anode, obj.cathode];
            
            if isempty(capacitance)
                obj.capacitance = sym(id);
            else
                obj.capacitance = sym(capacitance);
            end
            
            obj.impedance = 1/(sym('s') * obj.capacitance);
        end
        
        function str = to_net(obj)
            str = sprintf('%s %s %s %s\n', ...
                obj.id, num2str(obj.anode), num2str(obj.cathode), obj.capacitance);
        end
    end
end

