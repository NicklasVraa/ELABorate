% Part of ELABorate™, all rights reserved.
% Auth: Nicklas Vraa

classdef Indep_VS < Indep_S
% Independent Voltage Source.
    
    properties
        voltage;
    end
    
    methods
        function obj = Indep_VS(id, anode, cathode, type, voltage)
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
            
            if isempty(voltage)
                obj.voltage = sym(id);
            else
                obj.voltage = str2sym(string(voltage));
            end
        end
        
        function str = to_net(obj)
            if obj.is_AC, type = 'AC';
            else, type = 'DC'; end

            str = sprintf('%s %s %s %s %s\n', ...
                obj.id, num2str(obj.anode), num2str(obj.cathode), ...
                type, strrep(string(obj.voltage),' ',''));
        end
    end
end

