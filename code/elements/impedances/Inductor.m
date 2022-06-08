% Part of ELABorate, all rights reserved.
% Auth: Nicklas Vraa

classdef Inductor < Impedance
% A generic inductor class extending the impedance class.
% May be the basis for more specific inductors with their 
% own properties and methods.
    
    properties
        inductance;
    end
    
    methods
        function obj = Inductor(id, anode, cathode, inductance)
        % Inductor object constructor. Inductance is optional.

            if isempty(inductance)
                l = sym(id);
            else
                l = str2sym(string(inductance));
            end

            obj = obj@Impedance(id, anode, cathode, 1/(sym('s')*l));
            obj.inductance = l;
        end
        
        function str = to_net(obj)
        % Override of the super-class function.
        
            str = sprintf('%s %s %s %s\n', ...
                obj.id, num2str(obj.anode), num2str(obj.cathode), ...
                strrep(string(obj.inductance),' ',''));
        end

        function cloned = clone(obj)
            cloned = Inductor(obj.id, obj.anode, obj.cathode, obj.inductance);
        end
    end
end
