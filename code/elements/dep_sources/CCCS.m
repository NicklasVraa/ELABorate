% Part of ELABorate™, all rights reserved.
% Auth: Nicklas Vraa

classdef CCCS < Dep_S
% Current Controlled Current Source (F).
    
    properties
        beta_gain;
        num_terminals = 3;
    end
    
    methods
        function obj = CCCS(id, anode, cathode, ctrl_anode, beta_gain)
            obj.id = id;
            obj.anode = anode;
            obj.cathode = cathode;
            obj.ctrl_anode = ctrl_anode;
            obj.terminals = [obj.anode, obj.cathode, obj.ctrl_anode];
            
            if exist('beta_gain', 'var')
                obj.beta_gain = beta_gain;
            end
        end
        
        function str = to_net(obj)
            str = sprintf('%s %s %s %s %s\n', ...
                obj.id, num2str(obj.anode), num2str(obj.cathode), ...
                num2str(obj.ctrl_anode), obj.beta_gain);
        end
    end
end
