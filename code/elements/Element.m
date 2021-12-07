% Part of ELABorate™, all rights reserved.
% Auth: Nicklas Vraa

classdef Element < handle & matlab.mixin.Heterogeneous
% The basis for all circuit elements. All subclasses need 
% to implement the abstract properties and methods.
    
    properties
        id; terminals;
    end
    
    properties(Abstract)
        num_terminals;
    end
    
    methods(Abstract)
        % Return string representation of object.
        str = to_net(obj)
        
        % Check if this element is connected to node.
        bools = is_connected(obj, node)
        
        % Update terminal with new node value.
        update_terminals(obj, index, value)
    end
end

