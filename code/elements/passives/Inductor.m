% Part of ELABorate™, all rights reserved.
% Auth: Nicklas Vraa

classdef Inductor < Passive
    
    properties
        inductance; impedance;
    end
    
    methods
        function obj = Inductor(id, anode, cathode, inductance)
            obj.id = id;
            obj.anode = anode;
            obj.cathode = cathode;
            obj.terminals = [obj.anode, obj.cathode];
            
            if isempty(inductance)
                obj.inductance = sym(id);
            else
                obj.inductance = sym(inductance);
            end
            
            obj.impedance = sym('s') * obj.inductance;
        end
        
        function str = to_net(obj)
            str = sprintf('%s %s %s %s\n', ...
                obj.id, num2str(obj.anode), num2str(obj.cathode), obj.inductance);
        end
    end
end
