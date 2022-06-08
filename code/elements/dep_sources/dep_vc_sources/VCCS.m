% Part of ELABorate, all rights reserved.
% Auth: Nicklas Vraa

classdef VCCS < Dep_VC
% Voltage Controlled Current Source (G).
    
    properties
        gm_gain;
    end
    
    methods
        function obj = VCCS(id, anode, cathode, ctrl_anode, ctrl_cathode, gm_gain)
        % VCCS object constructor.

            if exist('gm_gain', 'var')
                gm = sym(gm_gain);
            end
            
            obj = obj@Dep_VC(id, anode, cathode, ctrl_anode, ctrl_cathode);
            obj.gm_gain = gm;
        end
        
        function str = to_net(obj)
            str = sprintf('%s %s %s %s %s %s\n', ...
                obj.id, num2str(obj.anode), num2str(obj.cathode), ...
                num2str(obj.ctrl_anode), num2str(obj.ctrl_cathode), obj.gm_gain);
        end

        function cloned = clone(obj)
            cloned = VCCS(obj.id, obj.anode, obj.cathode, ...
                obj.ctrl_anode, obj.gm_gain);
        end
    end
end

