% Part of ELABorate, all rights reserved.
% Auth: Nicklas Vraa

classdef Indep_VS < Indep_S
% Independent-voltage-source class implementing 
% its abstract super-class: independent source. 
% May be extended to implement non-ideal versions.
    
    properties
        voltage;
    end
    
    methods
        function obj = Indep_VS(id, anode, cathode, type, voltage)
        % Independant-voltage-source object constructor.
            
            if isempty(voltage)
                v = sym(id);
            else
                v = str2sym(string(voltage));
            end

            obj = obj@Indep_S(id, anode, cathode, type);
            obj.voltage = v;
        end
        
        function str = to_net(obj)
        % Override of the super-class function.

            if obj.is_AC, type = 'AC';
            else, type = 'DC'; end

            str = sprintf('%s %s %s %s %s\n', ...
                obj.id, num2str(obj.anode), num2str(obj.cathode), ...
                type, strrep(string(obj.voltage),' ',''));
        end

        function cloned = clone(obj)
            cloned = Indep_VS(obj.id, obj.anode, obj.cathode, ...
                obj.type, obj.voltage);
        end
    end
end