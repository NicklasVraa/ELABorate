% Part of ELABorate, all rights reserved.
% Auth: Nicklas Vraa

classdef Resistor < Impedance
% A generic resistor class extending the impedance class.
% May be the basis for more specific resistors with their 
% own properties and methods.
    
    properties
        resistance;
    end
    
    methods
        function obj = Resistor(id, anode, cathode, resistance)
        % Resistor object constructor. Resistance is optional.

            if isempty(resistance)
                r = sym(id);
            else
                r = str2sym(string(resistance));
            end

            obj = obj@Impedance(id, anode, cathode, r);
            obj.resistance = r;
        end

        function str = to_net(obj)
        % Override of the super-class function.
        
            str = sprintf('%s %s %s %s\n', ...
                obj.id, num2str(obj.anode), num2str(obj.cathode), ...
                strrep(string(obj.resistance),' ',''));
        end

        function cloned = clone(obj)
            cloned = Resistor(obj.id, obj.anode, obj.cathode, obj.resistance);
        end
    end
end

