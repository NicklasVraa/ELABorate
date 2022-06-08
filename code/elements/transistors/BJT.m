% Part of ELABorate, all rights reserved.
% Auth: Nicklas Vraa

classdef BJT < Transistor
% Bipolar Junction Transistor.
    
    properties
        base_node; collector_node; emitter_node;
        R_bb; R_cc; R_ee; % Optional internal resistances.
    end
    
    methods
        function obj = BJT(id, B, C, E, gain_val, R_bb, R_cc, R_ee)
            obj.id = id;
            obj.base_node = B;
            obj.collector_node = C;
            obj.emitter_node = E;
            obj.gain = sym(sprintf('beta_%s', id));
            
            if isempty(gain_val), obj.gain_val = obj.gain;
            else, obj.gain_val = sym(gain_val); end
            
            if isempty(R_bb), obj.R_bb = sym(sprintf('R_bb_%s', id));
            else, obj.R_bb = sym(R_bb); end
            
            if isempty(R_cc), obj.R_cc = sym(sprintf('R_cc_%s', id));
            else, obj.R_cc = sym(R_cc); end
            
            if isempty(R_ee), obj.R_ee = sym(sprintf('R_ee_%s', id));
            else, obj.R_ee = sym(R_ee); end
            
            obj.terminals = [obj.base_node, obj.collector_node, obj.emitter_node];
        end
        
        function str = to_net(obj)
            str = sprintf('%s %s %s %s %s\n', ...
                obj.id, num2str(obj.base_node), num2str(obj.collector_node), ...
                num2str(obj.emitter_node), obj.gain_val);
        end
        
        function bools = is_connected(obj, node)
            bools = [obj.base_node == node, obj.collector_node == node, ...
                     obj.emitter_node == node];
        end
        
        function internal(obj)
            fprintf('%s, Internal params:\n', obj.id);
            fprintf('- Base resistance  (R_bb): %s\n', obj.R_bb);
            fprintf('- Coll. resistance (R_cc): %s\n', obj.R_cc);
            fprintf('- Emit. resistance (R_ee): %s\n', obj.R_ee);
        end
        
        function update_terminals(obj, index, value)
            obj.terminals(index) = value;
            obj.base_node = obj.terminals(1);
            obj.collector_node = obj.terminals(2);
            obj.emitter_node = obj.terminals(3);
        end

        function cloned = clone(obj)
            cloned = BJT(obj.id, obj.base_node, obj.collector_node, ...
                obj.emitter_node, obj.gain);
        end
    end
end

