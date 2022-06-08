% Part of ELABorate, all rights reserved.
% Auth: Nicklas Vraa

classdef CCVS < Dep_CC
% Current Controlled Voltage Source (H).
    
    properties
        r_gain;
    end
    
    methods
        function obj = CCVS(id, anode, cathode, ctrl_anode, r_gain)
            obj.id = id;
            obj.anode = anode;
            obj.cathode = cathode;
            obj.ctrl_anode = ctrl_anode;
            obj.terminals = [obj.anode, obj.cathode];
            
            if exist('r_gain', 'var')
                obj.r_gain = r_gain;
            end
        end
        
        function str = to_net(obj)
            str = sprintf('%s %s %s %s %s\n', ...
                obj.id, num2str(obj.anode), num2str(obj.cathode), ...
                num2str(obj.ctrl_anode), obj.r_gain);
        end
    end
end

