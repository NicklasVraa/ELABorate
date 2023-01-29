% Part of ELABorate, all rights reserved.
% Auth: Nicklas Vraa

classdef CCVS < Dep_CC
% Current Controlled Voltage Source (H).
    
    properties
        r_gain;
    end
    
    methods
        function obj = CCVS(id, anode, cathode, ctrl_anode, r_gain)
        % CCVS object constructor.
            
            if exist('r_gain', 'var')
                r = sym(r_gain);
            end

            obj = obj@Dep_CC(id, anode, cathode, ctrl_anode);
            obj.r_gain = r;
        end
        
        function str = to_net(obj)
            str = sprintf('%s %s %s %s %s\n', ...
                obj.id, num2str(obj.anode), num2str(obj.cathode), ...
                num2str(obj.ctrl_anode), obj.r_gain);
        end

        function cloned = clone(obj)
            cloned = CCVS(obj.id, obj.anode, obj.cathode, ...
                obj.ctrl_anode, obj.r_gain);
        end
    end
end

