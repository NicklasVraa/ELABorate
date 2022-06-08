% Part of ELABorate, all rights reserved.
% Auth: Nicklas Vraa

classdef Indep_IS < Indep_S
% Independent-current-source class implementing 
% its abstract super-class: independent source.
% May be extended to implement non-ideal versions.
    
    properties
        current;
    end
    
    methods
        function obj = Indep_IS(id, anode, cathode, type, current)
        % Independant-current-source object constructor.
            
            if isempty(current)
                i = sym(id);
            else
                i = str2sym(string(current));
            end

            obj = obj@Indep_S(id, anode, cathode, type);
            obj.current = i;
        end
        
        function str = to_net(obj)
        % Override of the super-class function.

            if obj.is_AC, type = 'AC';
            else, type = 'DC'; end

            str = sprintf('%s %s %s %s %s\n', ...
                obj.id, num2str(obj.anode), num2str(obj.cathode), ...
                type, strrep(string(obj.current),' ',''));
        end

        function cloned = clone(obj)
            cloned = Indep_IS(obj.id, obj.anode, obj.cathode, ...
                obj.type, obj.current);
        end
    end
end