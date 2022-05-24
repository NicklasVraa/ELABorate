% Part of ELABorate™, all rights reserved.
% Auth: Nicklas Vraa

classdef Base_System < handle % & matlab.mixin.Heterogeneous
% The basis of all ELABorate's system classes.
    
    properties
        % Classifications.
        id; order; type;
        
        % Representations.
        s_domain; t_domain; transfer; state_space;
        diff_equation; zero_pole_gain; char_equation;
        
        % Plot data, to avoid having to calculate again.
        step_plot_data;
        bode_plot_data;
        nyquist_plot_data;
        
        % List of assumption about the system to decrease 
        % complexity of the calculations. 
        Assumptions;
    end
end

