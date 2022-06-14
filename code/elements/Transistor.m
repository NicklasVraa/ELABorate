% Part of ELABorate, all rights reserved.
% Auth: Nicklas Vraa

classdef (Abstract) Transistor < Element
% The abstract basis for all transistor variations.
    
    properties
        beta; % Amplification factor.
        biasing;
        num_terminals = 3;
    end
    
    methods
        function obj = Transistor(id, beta)
        % Transistor object constructor.

            obj.id = id;

            if isempty(beta)
                obj.beta = sym(sprintf('beta_%s', id));
            else
                obj.beta = sym(beta);
            end
        end
    end
end

