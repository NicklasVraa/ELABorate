% Part of ELABorate, all rights reserved.
% Auth: Nicklas Vraa

classdef BJT < Transistor
% Bipolar Junction Transistor.
    
    properties
        base_node; collector_node; emitter_node;

        % May be changed directly by the user.
        V_T = 0.026;  % Thermal voltage.
        V_BE = 0.7;   % Voltage drop across base-emitter junction.
        r_o;
    end
    
    methods
        function obj = BJT(id, B, C, E, beta)
            obj = obj@Transistor(id, beta);
            obj.base_node = B;
            obj.collector_node = C;
            obj.emitter_node = E;
            obj.r_o = sprintf('R_o_%s', id);
            obj.terminals = [obj.base_node, obj.collector_node, obj.emitter_node];
        end
        
        function str = to_net(obj)
            str = sprintf('%s %s %s %s %s\n', ...
                obj.id, num2str(obj.base_node), num2str(obj.collector_node), ...
                num2str(obj.emitter_node), obj.beta);
        end
        
        function bools = is_connected(obj, node)
            bools = [obj.base_node == node, obj.collector_node == node, ...
                     obj.emitter_node == node];
        end
        
        function update_terminals(obj, index, value)
            obj.terminals(index) = value;
            obj.base_node = obj.terminals(1);
            obj.collector_node = obj.terminals(2);
            obj.emitter_node = obj.terminals(3);
        end

        function cloned = clone(obj)
            cloned = BJT(obj.id, obj.base_node, obj.collector_node, ...
                obj.emitter_node, obj.beta);
        end
    end
end

