% Part of ELABorate, all rights reserved.
% Auth: Nicklas Vraa

classdef Resistor < Impedance
    
    properties
        resistance;
    end
    
    methods
        function obj = Resistor(id, anode, cathode, resistance)

            if isempty(resistance)
                r = sym(id);
            else
                r = str2sym(string(resistance));
            end

            obj = obj@Impedance(id, anode, cathode, r);
            obj.resistance = r;
        end

        function str = to_net(obj)
            str = sprintf('%s %s %s %s\n', ...
                obj.id, num2str(obj.anode), num2str(obj.cathode), ...
                strrep(string(obj.resistance),' ',''));
        end
    end
end

