% Part of ELABorate, all rights reserved.
% Auth: Nicklas Vraa

classdef MOSFET < Transistor
% Metal Oxide Semiconductor Field Effect Transistor (CMOS).
    
    properties
        gate_node; drain_node; source_node;

        % May be changed directly by the user.
        V_GS = 0.8; % Threshold voltage.
        K_c = 5;    % mA/V^2.
    end
    
    methods
        function obj = MOSFET(id, G, D, S, beta)
            obj = obj@Transistor(id, beta);
            obj.gate_node = G;
            obj.drain_node = D;
            obj.source_node = S;  
            obj.terminals = [obj.gate_node, obj.drain_node, obj.source_node];
        end
        
        function str = to_net(obj)
            str = sprintf('%s %s %s %s %s\n', ...
                obj.id, num2str(obj.gate_node), num2str(obj.drain_node), ...
                num2str(obj.source_node), obj.beta);
        end
        
        function bools = is_connected(obj, node)
            bools = [obj.gate_node == node, obj.drain_node == node, ...
                     obj.source_node == node];
        end
        
        function update_terminals(obj, index, value)
            obj.terminals(index) = value;
            obj.gate_node = obj.terminals(1);
            obj.drain_node = obj.terminals(2);
            obj.source_node = obj.terminals(3);
        end

        function cloned = clone(obj)
            cloned = MOSFET(obj.id, obj.gate_node, obj.drain_node, ...
                obj.source_node, obj.beta);
        end
    end
end

