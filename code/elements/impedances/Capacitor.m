% Part of ELABorate, all rights reserved.
% Auth: Nicklas Vraa

classdef Capacitor < Impedance
% A generic capacitor class extending the impedance class.
% May be the basis for more specific capacitors with their 
% own properties and methods.
    
    properties
        capacitance;
    end
    
    methods
        function obj = Capacitor(id, anode, cathode, capacitance)
        % Capacitor object constructor. Capacitance is optional.

            if isempty(capacitance)
                c = sym(id);
            else
                c = str2sym(string(capacitance));
            end

            obj = obj@Impedance(id, anode, cathode, sym('s')*c);
            obj.capacitance = c;
        end
        
        function str = to_net(obj)
        % Override of the super-class function.
        
            str = sprintf('%s %s %s %s\n', ...
                obj.id, num2str(obj.anode), num2str(obj.cathode), ...
                strrep(string(obj.capacitance),' ',''));
        end

        function cloned = clone(obj)
            cloned = Capacitor(obj.id, obj.anode, obj.cathode, obj.capacitance);
        end
    end
end

