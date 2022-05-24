% Part of ELABorate™, all rights reserved.
% Auth: Nicklas Vraa

classdef VCVS < Dep_VC
% Voltage Controlled Voltage Source (E).
    
    properties
        mu_gain;
    end
    
    methods
        function obj = VCVS(id, anode, cathode, ctrl_anode, ctrl_cathode, mu_gain)
            obj.id = id;
            obj.anode = anode;
            obj.cathode = cathode;
            obj.ctrl_anode = ctrl_anode;
            obj.ctrl_cathode = ctrl_cathode;
            obj.terminals = [obj.anode, obj.cathode, obj.ctrl_anode, obj.ctrl_cathode];
            
            if exist('mu_gain', 'var')
                obj.mu_gain = mu_gain;
            end
        end
        
        function str = to_net(obj)
            str = sprintf('%s %s %s %s %s %s\n', ...
                obj.id, num2str(obj.anode), num2str(obj.cathode), ...
                num2str(obj.ctrl_anode), num2str(obj.ctrl_cathode), obj.mu_gain);
        end
    end
end

