% Part of ELABorate, all rights reserved.
% Auth: Nicklas Vraa

classdef VCVS < Dep_VC
% Voltage Controlled Voltage Source (E).
    
    properties
        mu_gain;
    end
    
    methods
        function obj = VCVS(id, anode, cathode, ctrl_anode, ctrl_cathode, mu_gain)
        % VCVS object constructor.

            if exist('mu_gain', 'var')
                mu = sym(mu_gain);
            end
            
            obj = obj@Dep_VC(id, anode, cathode, ctrl_anode, ctrl_cathode);
            obj.mu_gain = mu;
        end
        
        function str = to_net(obj)
            str = sprintf('%s %s %s %s %s %s\n', ...
                obj.id, num2str(obj.anode), num2str(obj.cathode), ...
                num2str(obj.ctrl_anode), num2str(obj.ctrl_cathode), obj.mu_gain);
        end

        function cloned = clone(obj)
            cloned = VCVS(obj.id, obj.anode, obj.cathode, ...
                obj.ctrl_anode, obj.mu_gain);
        end
    end
end

