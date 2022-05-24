% Part of ELABorate™, all rights reserved.
% Auth: Nicklas Vraa

classdef VCCS < Dep_VC
% Voltage Controlled Current Source (G).
    
    properties
        gm_gain;
    end
    
    methods
        function obj = VCCS(id, anode, cathode, ctrl_anode, ctrl_cathode, gm_gain)
            obj.id = id;
            obj.anode = anode;
            obj.cathode = cathode;
            obj.ctrl_anode = ctrl_anode;
            obj.ctrl_cathode = ctrl_cathode;
            obj.terminals = [obj.anode, obj.cathode, obj.ctrl_anode, obj.ctrl_cathode];
            
            if exist('gm_gain', 'var')
                obj.gm_gain = gm_gain;
            end
        end
        
        function str = to_net(obj)
            str = sprintf('%s %s %s %s %s %s\n', ...
                obj.id, num2str(obj.anode), num2str(obj.cathode), ...
                num2str(obj.ctrl_anode), num2str(obj.ctrl_cathode), obj.gm_gain);
        end
    end
end

