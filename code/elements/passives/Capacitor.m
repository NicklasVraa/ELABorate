% Part of ELABorate™, all rights reserved.
% Auth: Nicklas Vraa

classdef Capacitor < Impedance
    
    properties
        capacitance;
    end
    
    methods
        function obj = Capacitor(id, anode, cathode, capacitance)

            if isempty(capacitance)
                c = sym(id);
            else
                c = sym(capacitance);
            end

            obj = obj@Impedance(id, anode, cathode, 1/(sym('s')*c));
            obj.capacitance = c;
        end
        
        function str = to_net(obj)
            str = sprintf('%s %s %s %s\n', ...
                obj.id, num2str(obj.anode), num2str(obj.cathode), obj.capacitance);
        end
    end
end

