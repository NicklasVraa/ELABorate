% Part of ELABorate™, all rights reserved.
% Auth: Nicklas Vraa

classdef Inductor < Impedance
    
    properties
        inductance;
    end
    
    methods
        function obj = Inductor(id, anode, cathode, inductance)
            
            if isempty(inductance)
                l = sym(id);
            else
                l = str2sym(string(inductance));
            end

            obj = obj@Impedance(id, anode, cathode, sym('s')*l);
            obj.inductance = l;
        end
        
        function str = to_net(obj)
            str = sprintf('%s %s %s %s\n', ...
                obj.id, num2str(obj.anode), num2str(obj.cathode), ...
                strrep(string(obj.inductance),' ',''));
        end
    end
end
