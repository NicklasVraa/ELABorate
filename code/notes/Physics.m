% Part of ELABorate, all rights reserved.
% Auth: Nicklas Vraa

classdef Physics
% A collection of physics notes and useful functions.

    methods(Static)
        
        function m_ind = miller(intercepts)
        % Takes plane interceptions with axes and returns miller indices.
        
            reciprocal = 1./intercepts;
            m_ind = reciprocal./gcd(reciprocal); % Greatest common denominator.
        end
    end
end

