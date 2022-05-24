% Part of ELABorate™, all rights reserved.
% Auth: Nicklas Vraa

classdef MOSFET < Transistor
% Metal Oxide Semiconductor Field Effect Transistor.
    
    properties
        gate_node; drain_node; source_node;
        R_gg; R_dd; R_ss; % Optional internal resistances.
    end
    
    methods
        function obj = MOSFET(id, G, D, S, gain_val, R_gg, R_dd, R_ss)
            obj.id = id;
            obj.gate_node = G;
            obj.drain_node = D;
            obj.source_node = S;
            obj.gain = sym(sprintf('beta_%s', id));
            
            if isempty(gain_val), obj.gain_val = obj.gain;
            else, obj.gain_val = sym(gain_val); end
            
            if isempty(R_gg), obj.R_gg = sym(sprintf('R_gg_%s', id));
            else, obj.R_gg = sym(R_gg); end
            
            if isempty(R_dd), obj.R_dd = sym(sprintf('R_dd_%s', id));
            else, obj.R_dd = sym(R_dd); end
            
            if isempty(R_ss), obj.R_ss = sym(sprintf('R_ss_%s', id));
            else, obj.R_ss = sym(R_ss); end
            
            obj.terminals = [obj.gate_node, obj.drain_node, obj.source_node];
        end
        
        function str = to_net(obj)
            str = sprintf('%s %s %s %s %s\n', ...
                obj.id, num2str(obj.gate_node), num2str(obj.drain_node), ...
                num2str(obj.source_node), obj.gain_val);
        end
        
        function bools = is_connected(obj, node)
            bools = [obj.gate_node == node, obj.drain_node == node, ...
                     obj.source_node == node];
        end
        
        function internal(obj)
            fprintf('%s, Internal params:\n', obj.id);
            fprintf('- Gate resistance   (R_bb): %s\n', obj.R_gg);
            fprintf('- Drain resistance  (R_cc): %s\n', obj.R_dd);
            fprintf('- Source resistance (R_ee): %s\n', obj.R_ss);
        end
        
        function update_terminals(obj, index, value)
            obj.terminals(index) = value;
            obj.gate_node = obj.terminals(1);
            obj.drain_node = obj.terminals(2);
            obj.source_node = obj.terminals(3);
        end
    end
end

