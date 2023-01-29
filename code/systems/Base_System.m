% Part of ELABorate, all rights reserved.
% Auth: Nicklas Vraa

classdef (Abstract) Base_System < handle
% The basis of all ELABorate's system classes.
    
    properties
        % Classifications.
        id; order; type;
        
        % Representations.
        s_domain; t_domain; transfer; state_space;
        diff_equation; zero_pole_gain; char_equation;
        
        % List of assumption about the system to decrease 
        % complexity of the calculations.
        Assumptions;
    end
end

