% Part of ELABorate, all rights reserved.
% Auth: Nicklas Vraa

classdef CCCS < Dep_CC
% Current Controlled Current Source (F).
    
    properties
        beta_gain;
    end
    
    methods
        function obj = CCCS(id, anode, cathode, ctrl_anode, beta_gain)
        % CCCS object constructor.
            
            if exist('beta_gain', 'var')
                beta = sym(beta_gain);
            end

            obj = obj@Dep_CC(id, anode, cathode, ctrl_anode);
            obj.beta_gain = beta;
        end
        
        function str = to_net(obj)
            str = sprintf('%s %s %s %s %s\n', ...
                obj.id, num2str(obj.anode), num2str(obj.cathode), ...
                num2str(obj.ctrl_anode), obj.beta_gain);
        end

        function cloned = clone(obj)
            cloned = CCCS(obj.id, obj.anode, obj.cathode, ...
                obj.ctrl_anode, obj.beta_gain);
        end
    end
end
