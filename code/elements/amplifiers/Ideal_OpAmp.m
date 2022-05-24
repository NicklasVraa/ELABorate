% Part of ELABorate™, all rights reserved.
% Auth: Nicklas Vraa

classdef Ideal_OpAmp < Amplifier
% Model of the Ideal Operational Amplifier.
    
    properties
        input_1; input_2; output;
    end
    
    methods
        function obj = Ideal_OpAmp(id, input_1, input_2, output)
            obj.id = id;
            obj.input_1 = input_1;
            obj.input_2 = input_2;
            obj.output = output;
            obj.terminals = [obj.input_1, obj.input_2, obj.output];
        end
        
        function str = to_net(obj)
            str = sprintf('%s %s %s %s\n', ...
                obj.id, num2str(obj.input_1), num2str(obj.input_2), num2str(obj.output));
        end
        
        function bools = is_connected(obj, node)
            bools = [obj.input_1 == node, obj.input_2 == node, obj.output == node];
        end
        
        function update_terminals(obj, index, value)
            obj.terminals(index) = value;
            obj.input_1 = obj.terminals(1);
            obj.input_2 = obj.terminals(2);
            obj.output  = obj.terminals(3);
        end
    end
end
