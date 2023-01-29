% Part of ELABorate, all rights reserved.
% Auth: Nicklas Vraa

classdef ODE
% Simply a container to make transmuting cleaner.    
    
    properties
        eq;
        cond;
    end
    
    methods
        function obj = ODE(eq, cond)
            obj.eq = eq;
            obj.cond = cond;
        end
    end
end

