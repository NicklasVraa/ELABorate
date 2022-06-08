% Part of ELABorate, all rights reserved.
% Auth: Nicklas Vraa

classdef (Abstract) Element < handle & matlab.mixin.Heterogeneous
% The abstract basis for all circuit elements. All sub-classes need 
% to implement the abstract properties and methods.
    
    properties
    % Shared by all sub-classes inheriting from this class.

        id; terminals;
    end
    
    properties(Abstract)
    % Properties must be implemented by sub-classes.

        num_terminals;
    end
    
    methods(Abstract)
    % Methods must be implemented by sub-classes.

        % Return string representation of object. Used to implement
        % netlist functionality, like updating the netlist.
        str = to_net(obj)
        
        % Check if this element is connected to the given node.
        bools = is_connected(obj, node)
        
        % Update terminal at index with new node value in given 
        % object (usually a circuit)
        update_terminals(obj, index, value)
        
        % Create clone of this object, which is an object itself, 
        % and not a reference to the original object, as is usually 
        % the case for Matlab objects.
        cloned = clone(obj)
    end
end

