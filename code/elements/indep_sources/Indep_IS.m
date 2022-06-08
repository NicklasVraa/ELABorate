% Part of ELABorate, all rights reserved.
% Auth: Nicklas Vraa

classdef Indep_IS < Indep_S
% Independent Current Source.
    
    properties
        current;
    end
    
    methods
        function obj = Indep_IS(id, anode, cathode, type, current)
            obj.id = id;
            obj.anode = anode;
            obj.cathode = cathode;
            obj.terminals = [obj.anode, obj.cathode];
            
            if strcmpi(type, 'AC')
                obj.is_AC = 1;
            elseif strcmpi(type, 'DC')
                obj.is_AC = 0;
            else
                error("Invalid type. Use 'AC' or 'DC'.");
            end
            
            if isempty(current)
                obj.current = sym(id);
            else
                obj.current = str2sym(string(current));
            end
        end
        
        function str = to_net(obj)
            if obj.is_AC, type = 'AC';
            else, type = 'DC'; end

            str = sprintf('%s %s %s %s %s\n', ...
                obj.id, num2str(obj.anode), num2str(obj.cathode), ...
                type, strrep(string(obj.current),' ',''));
        end
    end
end


